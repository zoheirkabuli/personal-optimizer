# Personal Ubuntu Optimizer

**How to Run**

```
bash <(wget -qO- raw.githubusercontent.com/zoheirkabuli/personal-optimizer/main/personal-optimizer.sh)
```

**Add this to crontab**

```
crontab -e
@reboot sleep 15 && caddy reload --config ./caddy.json
```
