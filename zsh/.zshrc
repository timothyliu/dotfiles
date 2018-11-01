# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

export HISTCONTROL=ignoreboth:erasedups
export EDITOR=nano
export GOPATH=~/code/go
export GOROOT=/usr/local/Cellar/go/1.11.1/libexec
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f ~/code/google-cloud-sdk/path.zsh.inc ]; then
  source ~/code/google-cloud-sdk/path.zsh.inc
fi

# The next line enables shell command completion for gcloud.
if [ -f ~/code/google-cloud-sdk/completion.zsh.inc ]; then
  source ~/code/google-cloud-sdk/completion.zsh.inc
fi

source <(kubectl completion zsh)

# alias ---

alias nano='/usr/local/Cellar/nano/2.9.0/bin/nano --smooth --tabstospaces --linenumbers'
alias awslog="~/code/k8s-scripts/awslog.sh"

alias knodes="~/code/k8s-scripts/node-info.sh"
alias kdeploy="~/code/k8s-scripts/deploy.sh"
alias kc='kubectl'
alias km='kc top po && kc top node && kc get po,hpa'
alias norun='kc get po --all-namespaces -o json | jq ".items[] | .metadata.namespace + \", \" + .metadata.name + \", \" + .status.phase + \", \" + .status.hostIP" | grep -v "Running"  | grep -v "Running"'
alias knode='kc get nodes -L spot-instance,kops.k8s.io/instancegroup,beta.kubernetes.io/instance-type'

# alias for K8S -----
alias util='kubectl get nodes --no-headers | awk '\''{print $1}'\'' | xargs -I {} sh -c '\''echo {} ; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo '\'''
#   Get CPU request total (we x20 because because each m3.large has 2 vcpus (2000m) )
alias cpualloc='util | grep % | awk '\''{print $1}'\'' | awk '\''{ sum += $1 } END { if (NR > 0) { print sum/(NR*20), "%\n" } }'\'''
#   Get mem request total (we x75 because because each m3.large has 7.5G ram )
alias memalloc='util | grep % | awk '\''{print $5}'\'' | awk '\''{ sum += $1 } END { if (NR > 0) { print sum/(NR*75), "%\n" } }'\'''
#   Get Pod cpu/mem reqs/limits
alias jqinfo1="jq -cr '.items[] | {name: .metadata.name, name2: .spec.containers[].name, phase: .status.phase, reqs: .spec.containers[].resources.requests, limits: .spec.containers[].resources.limits} | select(.phase == \"Running\") | [.reqs.cpu, .reqs.memory, .limits.cpu, .limits.memory, .name, .name2] | @tsv' | uniq"
alias jqhead1="echo '[\"CPU\",\"MEMORY\",\"L_CPU\",\"L_MEM\",\"name\"]' | jq -cr '. | @tsv'"
alias poduse="jqhead1; kc get po -o json | jqinfo1"
alias poduseall="jqhead1; kc get po --all-namespaces -o json | jqinfo1"


cal
date

PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
PS1='$(kube_ps1)'$PS1
PS1='$(echo -n `date +"[%H:%M:%S]"`)'$PS1

preexec () {
  DATE=`date +"%H:%M:%S on %Y-%m-%d"`
  C=$(($COLUMNS-24))
  echo -e "\033[1A\033[${C}C ${DATE} "
}
precmd() {}
