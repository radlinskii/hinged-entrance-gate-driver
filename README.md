# hinged-entrance-gate-driver

Project for AGH UST's  Concurrent and Distributed Programming course.

## Development

Before running the `gate_panel` program be sure to set the `GATE_IP_ADDRESS` environmental variable to your local IP address.<br>
Also, before running the`remote` or `photocell` programs you have to set the `GATE_IP_ADDRESS` variable to whatever IP address the `gate_panel` program is running at the time.

```bash
> export GATE_IP_ADDRESS="192.168.1.101"
```

> Note that you will only be able to send signal from the `remote` and `photocell` to `gate_panel` programs if they all are running on machines in the same network.
