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
    deployment:
        image: quay.io/apicurio/apicurio-registry-sql:2.3.0.Final