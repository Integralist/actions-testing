# Changelog

## [v1.0.0-beta.4](https://github.com/fastly/fastly-go/releases/tag/v1.0.0-beta.4) (2023-03-22)

**Bug fixes:**

- fix(purge): switch authentication type to 'token'

**Enhancements:**

- feat(domain-ownerships): List domain-ownerships
- feat(events): implement 'filter_created_at' property

**Documentation:**

- docs(backend): keepalive_time
- docs(object-store): restructure of the API documentation
- docs(pop): region, shield, latitude, longitude
- docs(product-enablement): brotli_compression
- docs(resource): terminology
- docs(results): fanout properties
- docs(tls/subscriptions): new 'failed' state
- docs(user): 'login' modification note removed

## [v1.0.0-beta.3](https://github.com/fastly/fastly-go/releases/tag/v1.0.0-beta.3) (2023-01-20)

**Enhancements:**

* Object Store API [commit](https://github.com/fastly/fastly-go/commit/e69498474f02c2208072160821a0d49c6999087d) 

## [v1.0.0-beta.2](https://github.com/fastly/fastly-go/releases/tag/v1.0.0-beta.2) (2023-01-18)

**Bug fixes:**

* Fixed OpenAPI schemas to produce missing methods for updating service settings [commit](https://github.com/fastly/fastly-go/commit/4c0423bfccbb4f62cb90f894f630b26306ffdc1a) 

## [v1.0.0-beta.1](https://github.com/fastly/fastly-go/releases/tag/v1.0.0-beta.1) (2023-01-17)

**Enhancements:**

* Update service settings API endpoint [commit](https://github.com/fastly/fastly-go/commit/0c29f6af943304085de0c999e45407e151600e3a) 
* Config Store API endpoints [commit](https://github.com/fastly/fastly-go/commit/0c29f6af943304085de0c999e45407e151600e3a) 

## [v1.0.0-beta.0](https://github.com/fastly/fastly-go/releases/tag/v1.0.0-beta.0) (2022-12-15)

**Enhancements:**

* New interface from code-generated API client [commit](https://github.com/fastly/fastly-go/commit/6b36bdea0aacc79321a1a970c57f0a31ca09ca45) 
  * [Blog post: Better Fastly API clients with OpenAPI Generator](https://dev.to/fastly/better-fastly-api-clients-with-openapi-generator-3lno)
  * [Documentation](https://github.com/fastly/fastly-go#documentation-for-api-endpoints)
  * [Unsupported API endpoints](https://github.com/fastly/fastly-go#issues)
