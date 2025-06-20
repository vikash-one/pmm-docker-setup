sh """
docker compose \
  -f docker-compose.base.yml \
  -f docker-compose.${params.ENV_TYPE}.yml \
  --env-file .env \
  up -d
"""
