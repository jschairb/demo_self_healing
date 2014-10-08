# Demo - Self-Healing Systems

**WIP**

A collection of tiny services demonstrating a collection of techniques to add Self-Healing behaviors to systems.

**This is intended for demonstrating several behaviors that allow a system to self-heal. As such, there are several practices I've skipped over including repeatability and security.**

## Services

### Base Service

### External Service

This is a small service that is intended to demonstrate an external dependency for the base system. It can be run via the following command:

```text
RACK_ENV=production ruby external_service.rb -p 80
```

There is a built-in failure threshold that can be set to simulate errors in HTTP responses. See below for further details.

#### GET `/failure_rate`

This resource provides the values used to calculate the rate of failures an API responds with.

```text
curl http://external-service.example.org/failure_rate
```

#### POST `/failure_rate`

This resource provides a mechanism to

```text
curl -H 'Content-Type: application/json' -X POST -d { 'rate': 80 } http://external-service.example.org/failure_rate
```

#### GET `/token`

Returns a representation of a token, including a timestamp and hostname.

```text
curl http://external-service.example.org/failure_rate
```





## Resources

* [Consul HTTP API documentation](http://www.consul.io/docs/agent/http.html)
* https://www.digitalocean.com/community/tutorials/an-introduction-to-using-consul-a-service-discovery-system-on-ubuntu-14-04
* https://gorails.com/setup/ubuntu/14.04
