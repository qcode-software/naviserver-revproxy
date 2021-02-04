Reverse Proxy Module for NaviServer
===================================

Release 0.14
------------

    neumann@wu-wien.ac.at

This is a NaviServer module that implements a reverse proxy for
NaviServer based on the ns_connchan command. The revproxy module
provides filter procs, which can be registered for all or for a view
selected URLs via wildcards, that will redirect the incoming requests
to some backend service. It is also possible to call the
revproxy::upstream directly from a server page (e.g. .vuh page),
allowing so e.g. in OpenACS only authenticated users or certain user
groups (admins) to use certain backend services.

When the filter procs are registered as "postauth" filters, it is
possible to use NaviServer (or e.g. OpenACS) as authenticating reverse
proxy server. It is possible to specify for every registered filter
- a target url,
- a list of regsub patterns (to e.g. remove certain parts from the current url),
- a timeout for establishing connections,
- a validation callback (to validate access of the service), and
- a exception callback (e.g. for returning tailored error pages).
- a url_rewrite_callback (e.g. for composing the final upstream URL).
- a backend_reply_callback (e.g. for modifying backend header fields)

Both the incoming and upstream connections might be based on http or
https. The implementation works as well with WebSockets (including
secure WebSockets).

The module requires at least NaviServer 4.99.14. The implementation is
based on nsf, which is available from e.g.  http://next-scripting.org/

***

Configuration:
--------------

In order to configure the reverse proxy, add the following lines to the
config file of NaviServer to make the ::revproxy::* functions available:

    ns_section "ns/server/${server}/modules"
       ns_param revproxy tcl

During startup of the server register the ::revproxy::upstream
function for some URLs, like in the following example, where GET and
POST requests  with /shiny/ are tunneled to some back end service
(here via https to my.backend.com).

    ns_register_filter postauth GET  /shiny/* ::revproxy::upstream -target https://my.backend.com/ -regsubs {{/shiny ""}}
    ns_register_filter postauth POST /shiny/* ::revproxy::upstream -target https://my.backend.com/ -regsubs {{/shiny ""}}

The registration of the folter might me happening e.g.
- in any kind of initialization script of the server (in an OpenACS context in a *-init.tcl file), or
- via the config file of the server, like in:

    ns_section "ns/server/${server}/module/revproxy"
       ns_param filters {
         ns_register_filter postauth GET  /shiny/* ::revproxy::upstream -target https://my.backend.com/ -regsubs {{/shiny ""}}
         ns_register_filter postauth POST /shiny/* ::revproxy::upstream -target https://my.backend.com/ -regsubs {{/shiny ""}}
       }

The registration of ::revproxy::upstream filter can be configured with
the following callbacks (see above) for a tailored behavior, more
flexible than the regsub approach sketched above:

    -exception_callback (default "::revproxy::exception")
        nsf::proc exception { -error -url } { ...}

    -url_rewrite_callback (default "::revproxy::rewrite_url")
        nsf::proc rewrite_url { -target -url {-query ""}} {....}

    -backend_reply_callback (default "")
        nsf::proc backend_reply_callback { -url -replyHeaders -status } {...}


Installation:
-------------

    apt-get install naviserver-revproxy


Authors:
--------

    Gustaf Neumann neumann@wu-wien.ac.at
