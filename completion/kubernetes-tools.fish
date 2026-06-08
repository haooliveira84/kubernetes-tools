function __ktools_current_namespace
    set -l current_context (kubectl config current-context 2>/dev/null)
    set -l namespace (kubectl config view -o=jsonpath="{.contexts[?(@.name==\"$current_context\")].context.namespace}")

    if test -z "$namespace"
        echo default
    else
        echo $namespace
    end
end

function __ktools_pods
    set -l pods (kubectl get pods -n (__ktools_current_namespace) --ignore-not-found --no-headers 2>/dev/null | awk '{print $1}')
    if set -q pods[1]
        printf "%s\tPod\n" $pods
    end
end

function __ktools_namespaces
    printf "%s\tNamespace\n" (kubectl get ns --no-headers 2>/dev/null | awk '{print $1}')
end

function __ktools_contexts
    printf "%s\tContext\n" (kubectl config get-contexts -o name 2>/dev/null)
end

function __ktools_nodes
    printf "%s\tNode\n" (kubectl get nodes --no-headers 2>/dev/null | awk '{print $1}')
end

function __ktools_deployments
    printf "%s\tDeployment\n" (kubectl get deployment -n (__ktools_current_namespace) --no-headers 2>/dev/null | awk '{print $1}')
end

function __ktools_services
    printf "%s\tService\n" (kubectl get svc -n (__ktools_current_namespace) --no-headers 2>/dev/null | awk '{print $1}')
end

function __ktools_secrets
    printf "%s\tSecret\n" (kubectl get secret -n (__ktools_current_namespace) --no-headers 2>/dev/null | awk '{print $1}')
end

complete -c klogs    -f -a '(__ktools_pods)'
complete -c kcopy    -f -a '(__ktools_pods)'
complete -c kexec    -f -a '(__ktools_pods)'
complete -c kpod     -f -a '(__ktools_pods)'
complete -c kdebug   -f -a '(__ktools_pods)'
complete -c kevents  -f -a '(__ktools_pods)'
complete -c kns      -f -a '(__ktools_namespaces)'
complete -c kctx     -f -a '(__ktools_contexts)'
complete -c knode    -f -a '(__ktools_nodes)'
complete -c krestart -f -a '(__ktools_deployments)'
complete -c kscale   -f -a '(__ktools_deployments)'
complete -c ksecret  -f -a '(__ktools_secrets)'

# kpf: -s switches from pods to services
complete -c kpf -f -s s -d 'Forward a service instead of a pod'
complete -c kpf -f -n 'not __fish_seen_argument -s s' -a '(__ktools_pods)'
complete -c kpf -f -n '__fish_seen_argument -s s'     -a '(__ktools_services)'
