import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# ==============================================================================
# Unit tests for stacks.aws Observe XRD
# ==============================================================================

_items = [
    # ==========================================================================
    # Test 1: Minimal input renders Observe and PodIdentity
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-observe-and-pod-identity"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata.name = "observe"
                    spec.clusterName = "my-cluster"
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-pod-identity"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-east-1"
                        serviceAccount = {
                            name = "k8s-monitoring-opencost"
                            namespace = "monitoring"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 2: Custom namespace propagates to both resources
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-namespace-propagates"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
                metadata.name = "observe"
                spec = {
                    clusterName = "prod-cluster"
                    namespace = "observability"
                    aws = {
                        region = "us-west-2"
                        rolePrefix = "prod-"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata.name = "observe"
                    spec.namespace = "observability"
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-pod-identity"
                    spec = {
                        rolePrefix = "prod-"
                        serviceAccount = {
                            namespace = "observability"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 3: Observe passthrough fields forwarded correctly
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "observe-passthrough-fields"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    k8sMonitoring = {
                        values = {
                            opencost = {
                                enabled = True
                            }
                        }
                    }
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata.name = "observe"
                    spec.k8sMonitoring = {
                        values = {
                            opencost = {
                                enabled = True
                            }
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 4: Provider config refs propagate correctly
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "provider-config-refs-propagate"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    helmProviderConfigRef = {
                        name = "custom-helm"
                        kind = "ClusterProviderConfig"
                    }
                    kubernetesProviderConfigRef = {
                        name = "custom-k8s"
                    }
                    awsProviderConfigRef = {
                        name = "custom-aws"
                    }
                    aws = {
                        region = "eu-west-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata.name = "observe"
                    spec = {
                        helmProviderConfigRef = {
                            name = "custom-helm"
                            kind = "ClusterProviderConfig"
                        }
                        kubernetesProviderConfigRef = {
                            name = "custom-k8s"
                            kind = "ProviderConfig"
                        }
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-pod-identity"
                    spec = {
                        providerConfigRef = {
                            name = "custom-aws"
                            kind = "ProviderConfig"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 5: Usage renders when both resources are ready
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "usage-renders-when-both-ready"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            observedResources = [
                {
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata = {
                        name = "observe"
                        annotations = {"crossplane.io/composition-resource-name" = "observe"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata = {
                        name = "observe-pod-identity"
                        annotations = {"crossplane.io/composition-resource-name" = "pod-identity"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
            ]
            assertResources = [
                {
                    apiVersion = "protection.crossplane.io/v1beta1"
                    kind = "Usage"
                    metadata.name = "observe-delete-observe-before-pod-identity"
                    spec = {
                        of = {
                            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                            kind = "PodIdentity"
                            resourceRef.name = "observe-pod-identity"
                        }
                        by = {
                            apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                            kind = "Observe"
                            resourceRef.name = "observe"
                        }
                        replayDeletion = True
                    }
                }
            ]
        }
    }
    # ==========================================================================
    # Test 6: S3 disabled by default — no S3 resources rendered
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "s3-disabled-no-s3-resources"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata.name = "observe"
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-pod-identity"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 7: Loki S3 enabled renders bucket, PodIdentity, and S3 resources
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "loki-s3-enabled-renders-resources"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                        loki = {
                            s3 = {
                                enabled = True
                                retentionDays = 30
                            }
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "Bucket"
                    metadata.name = "observe-loki-bucket"
                    metadata.annotations = {
                        "crossplane.io/external-name" = "observe-loki-storage"
                    }
                    spec.forProvider.region = "us-east-1"
                }
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "BucketPublicAccessBlock"
                    metadata.name = "observe-loki-bucket-pab"
                    spec.forProvider = {
                        blockPublicAcls = True
                        blockPublicPolicy = True
                        ignorePublicAcls = True
                        restrictPublicBuckets = True
                    }
                }
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta2"
                    kind = "BucketLifecycleConfiguration"
                    metadata.name = "observe-loki-bucket-lifecycle"
                    spec.forProvider.rule = [{
                        id = "expire-old-data"
                        status = "Enabled"
                        expiration = {days = 37}
                    }]
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-loki-pod-identity"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-east-1"
                        serviceAccount = {
                            name = "loki"
                            namespace = "monitoring"
                        }
                    }
                }
                {
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata.name = "observe"
                    spec.loki.values.loki.storage = {
                        type = "s3"
                        s3 = {
                            region = "us-east-1"
                            bucketNames = {
                                chunks = "observe-loki-storage"
                                ruler = "observe-loki-storage"
                                admin = "observe-loki-storage"
                            }
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 8: Tempo S3 enabled renders bucket, PodIdentity, and S3 resources
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "tempo-s3-enabled-renders-resources"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-west-2"
                        tempo = {
                            s3 = {
                                enabled = True
                                retentionDays = 14
                            }
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "Bucket"
                    metadata.name = "observe-tempo-bucket"
                    metadata.annotations = {
                        "crossplane.io/external-name" = "observe-tempo-storage"
                    }
                    spec.forProvider.region = "us-west-2"
                }
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "BucketPublicAccessBlock"
                    metadata.name = "observe-tempo-bucket-pab"
                }
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta2"
                    kind = "BucketLifecycleConfiguration"
                    metadata.name = "observe-tempo-bucket-lifecycle"
                    spec.forProvider.rule = [{
                        id = "expire-old-data"
                        status = "Enabled"
                        expiration = {days = 21}
                    }]
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "observe-tempo-pod-identity"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-west-2"
                        serviceAccount = {
                            name = "tempo"
                            namespace = "monitoring"
                        }
                    }
                }
                {
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata.name = "observe"
                    spec.tempo.values.tempo.storage.trace = {
                        backend = "s3"
                        s3 = {
                            bucket = "observe-tempo-storage"
                            endpoint = "s3.us-west-2.amazonaws.com"
                            region = "us-west-2"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 9: Custom bucket names are used
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-bucket-names"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                        loki = {
                            s3 = {
                                enabled = True
                                bucketName = "my-custom-loki-bucket"
                            }
                        }
                        tempo = {
                            s3 = {
                                enabled = True
                                bucketName = "my-custom-tempo-bucket"
                            }
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "Bucket"
                    metadata.name = "observe-loki-bucket"
                    metadata.annotations = {
                        "crossplane.io/external-name" = "my-custom-loki-bucket"
                    }
                }
                {
                    apiVersion = "s3.aws.m.upbound.io/v1beta1"
                    kind = "Bucket"
                    metadata.name = "observe-tempo-bucket"
                    metadata.annotations = {
                        "crossplane.io/external-name" = "my-custom-tempo-bucket"
                    }
                }
                {
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata.name = "observe"
                    spec.loki.values.loki.storage.s3.bucketNames = {
                        chunks = "my-custom-loki-bucket"
                        ruler = "my-custom-loki-bucket"
                        admin = "my-custom-loki-bucket"
                    }
                }
                {
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata.name = "observe"
                    spec.tempo.values.tempo.storage.trace.s3.bucket = "my-custom-tempo-bucket"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 10: S3 Usage renders when loki-pod-identity is ready
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "loki-s3-usage-renders-when-ready"
        spec = {
            compositionPath = "apis/observes/composition.yaml"
            xrdPath = "apis/observes/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "stacks.aws.hops.ops.com.ai/v1alpha1"
                kind = "Observe"
                metadata.name = "observe"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                        loki = {
                            s3 = {
                                enabled = True
                            }
                        }
                    }
                }
            }
            observedResources = [
                {
                    apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                    kind = "Observe"
                    metadata = {
                        name = "observe"
                        annotations = {"crossplane.io/composition-resource-name" = "observe"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata = {
                        name = "observe-pod-identity"
                        annotations = {"crossplane.io/composition-resource-name" = "pod-identity"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata = {
                        name = "observe-loki-pod-identity"
                        annotations = {"crossplane.io/composition-resource-name" = "loki-pod-identity"}
                    }
                    status = {
                        conditions = [{type = "Ready", status = "True"}, {type = "Synced", status = "True"}]
                    }
                }
            ]
            assertResources = [
                {
                    apiVersion = "protection.crossplane.io/v1beta1"
                    kind = "Usage"
                    metadata.name = "observe-delete-observe-before-loki-pod-identity"
                    spec = {
                        of = {
                            apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                            kind = "PodIdentity"
                            resourceRef.name = "observe-loki-pod-identity"
                        }
                        by = {
                            apiVersion = "stacks.hops.ops.com.ai/v1alpha1"
                            kind = "Observe"
                            resourceRef.name = "observe"
                        }
                        replayDeletion = True
                    }
                }
            ]
        }
    }
]

items = _items
