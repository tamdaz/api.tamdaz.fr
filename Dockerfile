FROM crystallang/crystal:1.16-alpine

RUN apk add --no-cache go-task

WORKDIR /app

COPY . .

CMD [ "sh", "-c", "cd /app && go-task build" ]