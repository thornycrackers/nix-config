job "memory-oversubscribe-2" {

  type = "system"

  group "memory-oversubscribe-2" {

    restart {
      attempts = 1
      delay    = "15s"
    }

    task "memory-oversubscribe-2" {
      driver = "docker"

      config {
        image              = "python:3.12"
        image_pull_timeout = "10m"
        entrypoint = ["python", "-c", <<EOF
import time
# Use up a bunch of memory
a = " " * (1 * 1024 * 1024 * 1024)

print("waiting", flush=True)
time.sleep(10000)
EOF
        ]

      }

      resources {
        cpu    = 400
        memory = 1100
        memory_max = 4000
      }

    }
  }
}

