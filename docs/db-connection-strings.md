# Database Connection Strings — P7 Database Administrator
**Cluster:** petclinic-cluster | **Region:** us-east-1 | **Namespace:** spring-petclinic  
**Verified:** 2026-05-14

---

## Secret (Credentials)

All three databases share one Kubernetes Secret:

```bash
kubectl get secret petclinic-db-secret -n spring-petclinic
```

| Key | Description |
|-----|-------------|
| `mysql-user` | App username (`petclinic`) |
| `mysql-password` | App user password |
| `mysql-root-password` | Root password |

Reference in your deployment YAML:
```yaml
env:
  - name: SPRING_DATASOURCE_USERNAME
    valueFrom:
      secretKeyRef:
        name: petclinic-db-secret
        key: mysql-user
  - name: SPRING_DATASOURCE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: petclinic-db-secret
        key: mysql-password
```

---

## customers-db — used by `customers-service` (P5)

| Property | Value |
|----------|-------|
| Pod | `customers-db-mysql-0` |
| Status | Running |
| ClusterIP | `172.20.37.167` |
| Pod IP | `10.0.3.76` |
| Port | `3306` |

**JDBC URL:**
```
jdbc:mysql://customers-db-mysql.spring-petclinic.svc.cluster.local:3306/petclinic
```

**Short form (within same namespace):**
```
jdbc:mysql://customers-db-mysql:3306/petclinic
```

**For `customers-service` deployment env:**
```yaml
- name: SPRING_DATASOURCE_URL
  value: "jdbc:mysql://customers-db-mysql:3306/petclinic"
- name: SPRING_PROFILES_ACTIVE
  value: "docker,mysql"
```

---

## vets-db — used by `vets-service` (P5)

| Property | Value |
|----------|-------|
| Pod | `vets-db-mysql-0` |
| Status | Running |
| ClusterIP | `172.20.196.142` |
| Pod IP | `10.0.3.211` |
| Port | `3306` |

**JDBC URL:**
```
jdbc:mysql://vets-db-mysql.spring-petclinic.svc.cluster.local:3306/petclinic
```

**Short form (within same namespace):**
```
jdbc:mysql://vets-db-mysql:3306/petclinic
```

**For `vets-service` deployment env:**
```yaml
- name: SPRING_DATASOURCE_URL
  value: "jdbc:mysql://vets-db-mysql:3306/petclinic"
- name: SPRING_PROFILES_ACTIVE
  value: "docker,mysql"
```

---

## visits-db — used by `visits-service` (P6)

| Property | Value |
|----------|-------|
| Pod | `visits-db-mysql-0` |
| Status | Running |
| ClusterIP | `172.20.124.137` |
| Pod IP | `10.0.3.135` |
| Port | `3306` |

**JDBC URL:**
```
jdbc:mysql://visits-db-mysql.spring-petclinic.svc.cluster.local:3306/petclinic
```

**Short form (within same namespace):**
```
jdbc:mysql://visits-db-mysql:3306/petclinic
```

**For `visits-service` deployment env:**
```yaml
- name: SPRING_DATASOURCE_URL
  value: "jdbc:mysql://visits-db-mysql:3306/petclinic"
- name: SPRING_PROFILES_ACTIVE
  value: "docker,mysql"
```

---

## Quick Connectivity Test Commands

```bash
# Test customers-db
kubectl exec -i customers-db-mysql-0 -n spring-petclinic -- \
  mysql -u petclinic -p<PASSWORD> petclinic -e "SELECT 'OK';"

# Test vets-db
kubectl exec -i vets-db-mysql-0 -n spring-petclinic -- \
  mysql -u petclinic -p<PASSWORD> petclinic -e "SELECT 'OK';"

# Test visits-db
kubectl exec -i visits-db-mysql-0 -n spring-petclinic -- \
  mysql -u petclinic -p<PASSWORD> petclinic -e "SELECT 'OK';"

# Get the password from the secret
kubectl get secret petclinic-db-secret -n spring-petclinic \
  -o jsonpath='{.data.mysql-password}' | base64 --decode
```

---

## Notes for P5 and P6

- Databases are ready — **no manual schema setup needed.** Spring Boot auto-runs `schema.sql` and `data.sql` on first startup when `mysql` profile is active.
- Always use the **Service DNS name** (e.g., `customers-db-mysql`), not the pod IP — pod IPs change on restart.
- All databases are `ClusterIP` (internal only) — not reachable from outside the cluster.
- Secret `petclinic-db-secret` already exists in the `spring-petclinic` namespace — just reference it in your deployment YAML.
