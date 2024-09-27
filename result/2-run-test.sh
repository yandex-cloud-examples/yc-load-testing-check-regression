#!/bin/bash

# печатать выполняемые команды + завершать скрипт при ошибке в выполняемой команде
set -ex

# сохраняем первые два аргумента командной строки в отдельные переменные
CONFIG_FILE=$1 # путь до файла конфигурации теста
TAG=$2 # метка-идентификатор типа теста

# создаем конфигурацию теста, id созданной конфигурации сохраняем в переменную с помощью утилиты jq
CONFIG_ID=$(yc --format json loadtesting test-config create --from-yaml-file "$CONFIG_FILE" | jq -r '.id')

# запускаем тест, указав флаг --wait, чтобы команда не завершалась до завершения самого теста
TEST=$(yc --format json loadtesting test create --name "example-com-$TAG" \
    --labels "service=example-com,load=$TAG" \
    --configuration "id=$CONFIG_ID,agent-by-filter=" \
    --wait \
)

# получаем ID только что проведенного теста с помощью утилиты jq и добавленного флага --format json
TEST_ID=$(echo "$TEST" | jq -r '.id')

# выводим результат test check-regression
yc loadtesting test check-regression "$TEST_ID"
