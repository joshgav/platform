apiVersion: registry.apicur.io/v1
kind: ApicurioRegistry
metadata:
    name: apicurio-registry
spec:
    configuration:
        persistence: sql
        sql:
            dataSource:
                url: ${DB_URL}
                userName: ${DB_USERNAME}
                password: ${DB_PASSWORD}