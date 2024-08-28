job "memory-oversubscribe" {

  type = "system"

  group "memory-oversubscribe" {

    restart {
      attempts = 1
      delay    = "15s"
    }

    task "memory-oversubscribe" {
      driver = "docker"

      config {
        image              = "python:3.12"
        image_pull_timeout = "10m"
        entrypoint = ["python", "-c", <<EOF
import time
import copy

memory_hog = []

for x in range(10000):
    memory_hog.append(" " * (30 * 1024 * 1024))
    time.sleep(1)

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

