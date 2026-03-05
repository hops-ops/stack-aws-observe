### What's changed in v0.1.0

* feat: initial commit (by @patrickleet)

* feat: loki + tempo s3 integrations (by @patrickleet)

* feat: usages of podid association (by @patrickleet)

* fix: BucketLifecycleConfiguration (by @patrickleet)

* feat: more usage debugging (by @patrickleet)

* fix: ordering + validate (by @patrickleet)

* fix: eks cluster version (by @patrickleet)

* fix: eks cluster version (by @patrickleet)

* feat: refactor (by @patrickleet)

* chore: validate steps (by @patrickleet)

* chore: manifest order for deletion (by @patrickleet)

* feat(deps): update crossplane-contrib/provider-aws-s3 docker tag to v2.4.0 (#6) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* feat: extra resource cleanup (#1) (by @patrickleet)

  Use `delete-extra-resources` in e2e workflow to control deletion of Observe stack and EKS Cluster with more control. Moved EKS into extraResources in the test, so only Observe gets deleted first. And then the extra resources can be deleted.


