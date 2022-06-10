# Alura DevOps Challenge

## Requisitos
- Instalar docker
- Copiar repo

## Build
Para fazer o build da image docker, abra o CMD dentro do repositório e rode o commando

```
docker build -t alura-devops:1.0 "."
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