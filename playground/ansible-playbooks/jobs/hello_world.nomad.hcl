job "hello-world" {

  type = "system"

  group "hello-world" {

    network {
      port "hello-world" {
        static = 8000
      }
    }


    restart {
      attempts = 10
      interval = "5m"
      delay    = "15s"
      mode     = "delay"
    }

    task "hello-world" {
      driver = "docker"

      config {
        image              = "thornycrackers/helloworld"
        image_pull_timeout = "10m"
        ports = ["hello-world"]
      }

      resources {
        cpu    = 400
        memory = 1000
      }

      service {
        name = "hello-world"
        port = "hello-world"
        provider = "consul"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.http.rule=Host(`example.com`)",
        ]

      }
    }
  }
}

