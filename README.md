## Wordpress / PHP 7 / Apache 2 / CentOS Docker image

This is based off of [Codecloud's docker image](https://github.com/codecloud/docker-centos-apache-php7) and [Wordpress docker library](https://github.com/docker-library/wordpress/tree/0a5405cca8daf0338cf32dc7be26f4df5405cfb6/php7.0/apache)

Pull the docker container using:

    docker pull csandeep/centos-php7-apache-wordpress

Here's a sample **docker-compose.yml** to get you started:

    version: "2"
    services:
      test-wpdb:
        image: mariadb
        ports:
          - "8081:3306"
        environment:
          MYSQL_ROOT_PASSWORD: password
        volumes:
              - ./.data:/var/lib/mysql
      test-wp:
        image: csandeep/centos-php7-apache-wordpress-latest:latest
        volumes:
          - ./:/var/www
        ports:
          - "80:80"
        links:
          - test-wpdb:mysql
        environment:
          WORDPRESS_DB_PASSWORD: password
          SERVERNAME: test-dev