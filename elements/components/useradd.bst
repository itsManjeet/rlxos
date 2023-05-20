kind: import

sources:
- kind: local
  path: files/useradd

config:
  source: /
  target: "%{sysconfdir}/default"