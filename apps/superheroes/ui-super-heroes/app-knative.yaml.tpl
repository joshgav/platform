---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: ui-super-heroes
spec:
  template:
    spec:
      containers:
        - image: quay.io/${container_image_group_name}/ui-super-heroes:latest
          name: ui-super-heroes
          env:
            - name: CALCULATE_API_BASE_URL
              value: 'true'
          imagePullPolicy: Always
          livenessProbe:
            failureThreshold: 3
            httpGet:
              path: /
              scheme: HTTP
            initialDelaySeconds: 0
            periodSeconds: 30
            successThreshold: 1
            timeoutSeconds: 10
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /
              scheme: HTTP
            initialDelaySeconds: 0
            periodSeconds: 30
            successThreshold: 1
            timeoutSeconds: 10
          ports:
            - containerPort: 8080
              name: http1
              protocol: TCP
          resources:
            limits:
              memory: 128Mi
            requests:
              memory: 32Mi
