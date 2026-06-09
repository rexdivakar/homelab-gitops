# Popeye

Popeye is deployed as a nightly CronJob that scans cluster resources. It has no web login surface and therefore does not use Keycloak.

To run manually:

```sh
kubectl create job -n popeye --from=cronjob/popeye popeye-manual
kubectl logs -n popeye job/popeye-manual
```
