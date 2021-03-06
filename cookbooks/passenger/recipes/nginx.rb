require_recipe "nginx"

gem_package "passenger" do
  version node[:passenger][:nginx][:passenger_version]
end

package "libgeoip-dev"
package "libxslt1-dev"
package "libpcre3-dev"
package "libgd2-noxpm-dev"
package "libssl-dev"
package "build-essential"
package "zlib1g-dev"

nginx_path = "/tmp/nginx-#{node[:passenger][:nginx][:nginx_version]}"

log "nginx_path = #{nginx_path}"

remote_file "#{nginx_path}.tar.gz" do
  action :create_if_missing
  cookbook "nginx"
  source "http://nginx.org/download/nginx-#{node[:passenger][:nginx][:nginx_version]}.tar.gz"
end

execute "extract nginx" do
  command "tar -C /tmp -xzf #{nginx_path}.tar.gz"
  creates nginx_path
end

# default options from Ubuntu 8.10
compile_options = ["--conf-path=/etc/nginx/nginx.conf",
                   "--error-log-path=/var/log/nginx/error.log",
                   "--pid-path=/var/run/nginx.pid",
                   "--lock-path=/var/lock/nginx.lock",
                   "--http-log-path=/var/log/nginx/access.log",
                   "--http-client-body-temp-path=/var/lib/nginx/body",
                   "--http-proxy-temp-path=/var/lib/nginx/proxy",
                   "--http-fastcgi-temp-path=/var/lib/nginx/fastcgi",
                   "--with-http_stub_status_module",
                   "--with-http_ssl_module",
                   "--with-http_gzip_static_module",
                   "--with-http_geoip_module",
                   "--with-file-aio"].join(" ")

log "  ==> nginx -V 2>&1 | grep passenger-#{node[:passenger][:nginx][:nginx_version]}"

execute "compile nginx with passenger" do
  command "passenger-install-nginx-module --auto --prefix=/usr --nginx-source-dir=#{nginx_path} --extra-configure-flags=\"#{compile_options}\""
  notifies :restart, resources(:service => "nginx")
  not_if "nginx -V 2>&1 | grep passenger-#{node[:passenger][:nginx][:passenger_version]}"
end

template node[:nginx][:conf_dir] + "/passenger.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :restart, resources(:service => "nginx")
end