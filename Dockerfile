# imagem docker base
FROM python:3.10-alpine

# pasta que vamos executar os comandos
WORKDIR /app-python-aluraDevops

# variáveis para criação do super usuário do Djando 
ENV DJANGO_SUPERUSER_EMAIL=admin@alura.com
ENV DJANGO_SUPERUSER_USERNAME=admin
ENV DJANGO_SUPERUSER_PASSWORD=admin123

# copiando todos os arquivo para dentro da imagem docker
COPY . .

# update dependences
RUN pip install --upgrade pip
# instalando os requirements
RUN pip install -r requirements.txt

# criando o django database
RUN python manage.py makemigrations && python manage.py migrate && python manage.py createsuperuser --noinput

# containert port
EXPOSE 8081

# rodando o django na port 8081
ENTRYPOINT python manage.py runserver 0.0.0.0:8081
