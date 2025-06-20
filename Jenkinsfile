pipeline {
  parameters {
    choice(name: 'ENV_TYPE', choices: ['poc', 'prod'], description: 'Choose environment')
  }

  agent any

  stages {
    stage('Deploy PMM') {
      steps {
        script {
          sh 'cp .env.example .env'
          sh """
            docker compose -f docker-compose.base.yml -f docker-compose.${params.ENV_TYPE}.yml \
              --env-file .env up -d
          """
        }
      }
    }
  }
}
