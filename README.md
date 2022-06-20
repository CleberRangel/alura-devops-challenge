# Alura DevOps Challenge
___
## Criação da imagem do projeto

## Requisitos
- Instalar docker
- Copiar repo

## Build
Para fazer o build da image docker, abra o CMD dentro do repositório e rode o commando

```
docker build -t cleberrangeljr/alura-devops-challenge:1.0 "."
```

Verifique se a imagem docker foi criada execute `docker images` no terminal

```
REPOSITORY     TAG       IMAGE ID       CREATED          SIZE
alura-devops   1.0       ec46d8795eac   11 minutes ago   968MB
```

Para executar a imagem em um container execute `docker run -d -p 8000:8081 alura-devops:1.0`

Para acessar a aplicação no seu computador local acesse: http://localhost:8000/programas/

Usuário: admin
Pass: admin123

___

## Upload para AWS Elastic Container Service

## Cluster
Acesse o painel do Elastic Container Service (ECS) e siga os passos:

- Crie um Cluster
    - EC2 Linx + Networking
        - Nome: `alura-devops-cluster`
        - EC2 Type: t2.micro
        - Networking: Create a new VPC (Deixe o wizard criar)
        - IAM Role: Create new role (Deixe o wizard criar)

## Task Definition

Uma vez o cluster criado, vamos criar a Task com para o container dentro do menu `Task Definitions`

 - Crie uma nova Task Definition
    - Type: EC2, pois o nosso cluser é do typo EC2
    - Nome: `alura-devops-container`
    - Task Role: `ecsTaksExecutionRole`, esta role é criada automaticamente quando o cluster é criado e o wizard cria a IAM Role para o cluster.
    - Network mode: Bridge, o nosso container ira se comunicar com o host
    - Task Execution Role: `ecsTaksExecutionRole`
    - Cotainer Definition: Crie um novo container
        - Nome: `devops-contaier`
        - Image: `cleberrangeljr/alura-devops-challenge:1.4`
        - Memory Limits: Soft Limit: 256
        - Port Mappings: 
            - Host Port: Vazio (Deixe a task automaticamente selecionar)
            - Container Port: 8081 (A Aplicação roda nesta porta)
        - Environment variables (Crie uma)
            - `HOST_IP`

## Load Balancer
Vamos criar uma load balancer, para caso uma das Tasks que criamos falhe o trafego possa ser roteado para a Task que esteja funcionando.

Acesse o painel de configurações do EC2 e acesso o menu do `Load Balancers` e crie um novo.

- Type: Application Load Balancer, no nosso caso vamos somente trafego de HTTP.
- Nome: `alura-devops-balancer`
- Networking Mapping
    - Mappings: Selecione 2 Zonas
- Listeners and Routing
    - Dentro do Listerer HTTP:80 (Devemos criar um novo target group)
        - Name: `alura-target`
        - Type: Application Load Balancer
        - Port: 80
    - Selecione o Target Grupo criado

Vamos utilizar esta Load Balancer na criação do nosso Service.


## Service

Uma vez que temos a nossa Task criada, podemos criar o serviço para roda-lá.

Dentro do menu do `Clusters`, na aba `Services` crie uma novo Serviço:

- Type: EC2
- Task Definition: `alura-devops-container`
- Cluster: `alura-devops-cluster`
- Service Name: `alura-devop-service`
- Number of Tasks: 2, para serem redundantes
- Load balancing
    - Type: Application Load Balancer
    - Name: `alura-devops-balancer`
- Container to Load balance
    - Add load balancer
        - Target group: `alura-target` (Veja: que o Listener Port esta na porta 80:HTTP)
- Avance o Wizard até o final.

## Acessar Aplicação

Dentro do painel do EC2, acesse o painel de configuração para o `Load Balancers`.
Como o Load Balancer `alura-devops-balancer` selecionado, na aba `Description` veja o `DNS Name` este é o "site" para acessar a aplicação.

Tentado acessar um `503` vai aparecer, isto acontece pelo este host name não estar liberado para acessar o DJANGO. Durante a criação da task `alura-devops-container` foi denifido uma Environment variable chamada `HOST_IP`, devemos configurar esta variavél com o DNS do load balancer.

### Atualizando Task

No painel de configuração do ECS, acesse o menu `Task Definitions` e acesse a task `alura-devops-container`, marque a `alura-devops-container:1` e cria uma nova revisão.

Em `Container definitions`, clique para editar o container `devops-contaier` e confgure o valor do `HOST_IP` para ter o mesmo nome do DNS utilizado pelo `alura-devops-balancer`.

Finalize o Wizard.

Uma versão `alura-devops-container:2` deve aparecer na listagem de versões da Task.

### Atualizando Service
O Service deve ser atualizado para utilizar a nova versão da Task.

O menu `Clusters` do ECS na aba `Services` marque o serviço `alura-devop-service` e selecione `Update`.

Dentro da `Task Definition` selecione a revisão 2 da `alura-devops-container` e avance o Wizard até o final.

Na aba `Tasks` da configuração cluster `alura-devops-cluster` terá duas 2 tasks, como configurado na criação do `alura-devop-service`, na coluna `Task definition` verifique a versão da task, quando este mostar a `alura-devops-container:2` tente acessar o endereço de DNS do Load Balancer novamente.

Boa...completou mais uma fase!!!

___

## Rotina de Continuous Integration

O repositório esta configurado para automaticamente publicar atualizações do código para o Docker Hub `cleberrangeljr/alura-devops-challenge`.

Para tal, é preciso criar uma tag no formato `*.*` e publicar no `main` branch, com isso uma git hub workflow vai ser iniciado.

Exemplo:
 - Modificar o código do repositório
 - Fazer um push com as modificações para o branch `main`
 - Criar tag com o número da próxima versão da image do Docker Hub, ex: `1.6`
 - Push da tag para o branch `main`
 - Verificar o workflow foi iniciado na aba `Actions` do repositório.

 ___

## Rotina de Continuous Delivery

O workflow de Continuous Delivery acontece logo após o do Continuous Integration, caso nenhum erro aconteça.

Uma nova task no AWS ECS e criada e configurada no Serviço `alura-service-devops`

Para fazer o deply to ECS a action [DonaldPiret ECS Deployment](https://github.com/marketplace/actions/ecs-deployment) que utiliza o pacote do [ECS Deploy](https://github.com/fabfuel/ecs-deploy) do Fabian Fuelling.

Dentro do pasta `.github/workflows` existem 2 arquivos de workflow:
- main.yml
    - Roda o CI do projeto, criando uma nova image no Docker Hub
    - Chama o aws_deploy.yml após o CI ter rodado com sucesso.
- aws_deploy.yml
    - Atualiza a task dentro to serviço da AWS ECS.





