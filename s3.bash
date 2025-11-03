#!/bin/bash

# --- Configuration ---
# Ces valeurs sont extraites de votre YAML.
# VÉRIFIEZ qu'elles correspondent à votre installation NooBaa / OpenShift Storage.
STORAGE_CLASS="openshift-storage.noobaa.io"
BUCKET_CLASS="noobaa-default-bucket-class"

echo "Début de la création des 40 ObjectBucketClaims..."
echo "StorageClass: $STORAGE_CLASS"
echo "BucketClass: $BUCKET_CLASS"
echo "---"

for i in $(seq 1 40); do
  NAMESPACE="project-$i"
  # Nom de la ressource OBC (ex: 'default-bucket' dans 'project-1')
  OBC_NAME="default-project-bucket"
  # Préfixe pour le nom du VRAI bucket S3 (sera généré)
  BUCKET_NAME_PREFIX="project-$i-bucket-"

  echo "Création du bucket claim '$OBC_NAME' dans le namespace '$NAMESPACE'..."

  # Utilise un "here document" (<<EOF) pour passer le YAML à 'oc apply'
  oc apply -f - <<EOF
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  # Le nom de la ressource Kubernetes OBC
  name: ${OBC_NAME}
  # Le namespace où créer l'OBC
  namespace: ${NAMESPACE}
spec:
  # Le préfixe du nom de bucket S3 qui sera généré
  generateBucketName: ${BUCKET_NAME_PREFIX}
  
  # Le provisionneur de stockage (NooBaa)
  storageClassName: ${STORAGE_CLASS}
  
  # Configuration additionnelle (classe de bucket NooBaa)
  additionalConfig:
    bucketclass: ${BUCKET_CLASS}
EOF

  if [ $? -ne 0 ]; then
    echo "ERREUR: Échec de la création du bucket dans $NAMESPACE."
    echo "Vérifiez si le namespace existe et si 'oc' est bien connecté."
  fi
  echo "---"
done

echo "Terminé. Les 40 ObjectBucketClaims ont été envoyés."
