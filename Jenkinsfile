pipeline {
    agent {
        dockerfile {
            label 'amd64'
            dir '.jenkins'
        }
    }
    stages {
        stage('Build') {
            steps {
                sh 'npm ci'
                sh 'npm run build'
                sh 'npm run package-win'
                sh 'cd $WORKSPACE/builds/tahskr-win32-ia32 && zip -r $WORKSPACE/tahskr-win.zip .'
                sh 'cd $WORKSPACE/dist && zip -r $WORKSPACE/tahskr-web.zip .'
                stash name: 'Builds', includes: '*.zip'
            }
        }
        stage('Release') {
            when { branch 'master' }
            environment {
                GIT_REPO_SLUG = 'Dullage/tahskr'
                GITHUB_TOKEN = credentials('github_token')
            }
            steps {
                unstash 'Builds'
                sh 'bash $WORKSPACE/.jenkins/release.sh'
            }
        }
        stage ('Integrate') {
            when { anyOf { branch 'master'; branch 'develop' } }
            environment {
                SSH_KEY = credentials('droplet_ssh_key')
                DEPLOY_IP = credentials('droplet_ip')
            }
            steps {
                unstash 'Builds'
                sh 'unzip tahskr-web.zip -d $WORKSPACE/dist'
                sh 'rsync -r --delete --perms --chmod=775 -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" $WORKSPACE/dist/ jenkins@$DEPLOY_IP:~/tahskr/$BRANCH_NAME'
            }
        }
    }
}
