Addresses are assigned to registered interfaces. They can be configured from <em>ranges</em> of addresses set by your site administrator.
Alternatively, you can specify the address that you wish to assign (if available).
<p>
    The <em>Configuration</em> field allows you to specify how you will receive your IP address. DHCP will statefully
    lease your address to you. This also takes care of creating your DNS records upon handout of the lease. Static is
    only for when you have set your IP address manually on your machine. This will create the DNS records immediately. 
</p>
<p>
    Different DHCP <em>classes</em> can be used depending on the desired boot functionality.
</p>
<p>
    The <em>Primary Address</em> of an interface is the only one that can be DHCP-able, and should be the address that you
    logically consider the "main" one.
</p>
<p>
    Comments are optional.
</p>