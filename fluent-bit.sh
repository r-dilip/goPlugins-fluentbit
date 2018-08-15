#install fluentbit on omsagent's pod
wget -qO - https://packages.fluentbit.io/fluentbit.key | sudo apt-key add -
sudo echo "deb https://packages.fluentbit.io/ubuntu/xenial xenial main" >> /etc/apt/sources.list  
sudo apt-get update
sudo apt-get install td-agent-bit sqlite3 libsqlite3-dev

#start fluent-bit
/opt/td-agent-bit/bin/td-agent-bit -c /etc/td-agent-bit/td-agent-bit.conf

# #Check if ruby is using jemalloc
# ruby -r rbconfig -e "puts RbConfig::CONFIG['LIBS']"

# kubectl exec -it -n kube-system omsagent-mt9fn  /bin/bash

# #attempt to automate shit
# $clusterName = "dilipr-devnull"
# az aks get-credentials -n $clusterName -g $clusterName
# $omsAgentPodName = "omsagent-l9zrv"
# kubectl exec -it $omsAgentPodName -n kube-system /bin/bash
# $omsAgentId = "06fc8090-a650-4db2-a95a-adde1d2fee79"

# kubectl cp /fluentd/jemalloc/container.conf kube-system/omsagent-mt9fn:/etc/opt/microsoft/omsagent/06fc8090-a650-4db2-a95a-adde1d2fee79/conf/omsagent.d/container.conf
# kubectl cp  /fluentd/jemalloc/td-agent-bit.conf kube-system/omsagent-mt9fn:/etc/td-agent-bit/td-agent-bit.conf


# kubectl cp /fluentd/fb-jemalloc/container.conf kube-system/omsagent-m6864:/etc/opt/microsoft/omsagent/06fc8090-a650-4db2-a95a-adde1d2fee79/conf/omsagent.d/container.conf
# kubectl cp  /fluentd/fb-jemalloc/td-agent-bit.conf kube-system/omsagent-m6864:/etc/td-agent-bit/td-agent-bit.conf



# opt/microsoft/omsagent/ruby/lib/pkgconfig/ruby-2.4.pc
# opt/microsoft/omsagent/ruby/lib/ruby/2.4.0/x86_64-linux/rbconfig.rb
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/gems/cool.io-1.5.3/ext/cool.io/Makefile
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/gems/cool.io-1.5.3/ext/iobuffer/Makefile
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/gems/json-2.1.0/ext/json/Makefile
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/gems/json-2.1.0/ext/json/ext/parser/Makefile
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/gems/json-2.1.0/ext/json/ext/generator/Makefile
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/gems/oj-2.17.0/ext/oj/Makefile
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/gems/string-scrub-0.0.5/ext/string/Makefile
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/gems/yajl-ruby-1.3.1/ext/yajl/Makefile
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/gems/http_parser.rb-0.6.0/ext/ruby_http_parser/Makefile
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/gems/msgpack-1.1.0/ext/msgpack/Makefile
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/extensions/x86_64-linux/2.4.0-static/cool.io-1.5.3/mkmf.log
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/extensions/x86_64-linux/2.4.0-static/json-2.1.0/mkmf.log
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/extensions/x86_64-linux/2.4.0-static/string-scrub-0.0.5/mkmf.log
# opt/microsoft/omsagent/ruby/lib/ruby/gems/2.4.0/extensions/x86_64-linux/2.4.0-static/msgpack-1.1.0/mkmf.log


# #!/bin/bash

# ACR_NAME=dougcontainerregistry
# SERVICE_PRINCIPAL_NAME=dilipr-dougacr-sp

# # Populate the ACR login server and resource id.
# ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
# ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)

# # Create a 'Reader' role assignment with a scope of the ACR resource.
# SP_PASSWD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --role Reader --scopes $ACR_REGISTRY_ID --query password --output tsv)

# # Get the service principal client id.
# CLIENT_ID=$(az ad sp show --id http://$SERVICE_PRINCIPAL_NAME --query appId --output tsv)

# # Output used when creating Kubernetes secret.
# echo "Service principal ID: $CLIENT_ID"
# echo "Service principal password: $SP_PASSWD"

# kubectl create secret docker-registry acr-auth --docker-server dougcontainerregistry.azurecr.io --docker-username 5d0cb5cd-7bb2-4f98-9494-4e25c75590d1 --docker-password 077558fd-51a8-4f67-be0f-eb3d8dafae44 --docker-email dilipr@microsoft.com

# 6bb1e963-b08c-43a8-b708-1628305e964a
# YonW5ePdSytdCh+zAgG3pMiCaehbXcaf/AaNdRZH2OaN362f/feXcCVwYWgRIGvZ5v9zmV0TmGXDE1so7mNrUg==


# # 8/7/2018
# # download and install go 
# # Download tar file and update env variables
# tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
# export PATH=$PATH:/usr/local/go/bin
# source $HOME/.profile

# # 
# git clone https://github.com/fluent/fluent-bit-go.git
# # sudo apt install golang-go -- this doesnt work!! 
# sudo apt-get install gcc
# sudo go get "github.com/fluent/fluent-bit-go/output"
# go build -buildmode=c-shared -o out_gstdout.so out_gstdout.go

# #Compile Fluent Bit with Golang support, e.g:

# cd build/
# cmake -DFLB_DEBUG=On -DFLB_PROXY_GO=On ../
# make

# #once compiled, we can see a new option in the binary -e which stands for external plugin, e.g:
# bin/fluent-bit -h # help 

# # -e, --plugin=FILE	load an external plugin (shared lib)

# go build -buildmode=c-shared -o /home/dilipr/fluent-bit-go/examples/out_oms/out_oms.so /home/dilipr/fluent-bit-go/examples/out_oms/out_oms.go
# kubectl cp /home/dilipr/fluent-bit-go/examples/out_oms/out_oms.so kube-system/omsagent-ftk2v:/etc/td-agent-bit
# kubectl exec -it -n kube-system omsagent-ftk2v /bin/bash
# /opt/td-agent-bit/bin/td-agent-bit -c /etc/td-agent-bit/td-agent-bit.conf -e /etc/td-agent-bit/out_oms.so


# kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-service-account.yaml
# kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-role.yaml
# kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-role-binding.yaml
# kubectl create -f https://github.com/fluent/fluent-bit-kubernetes-logging/blob/master/output/elasticsearch/fluent-bit-configmap.yaml
