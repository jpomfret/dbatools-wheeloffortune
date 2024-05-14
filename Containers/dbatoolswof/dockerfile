###
#
#   temp/builder image: add users, logins, databases, etc
#
###

# get the latest SQL container and set it as the builder image
FROM dbatools/mssqlbase as builder

# switch to root to a bunch of stuff that requires elevated privs
USER root

# set the pwd and chown to the service account
WORKDIR /tmp
RUN chown mssql /tmp

# copy scripts and make bash files executable
# use copy instead of add, it's safer apparently
COPY sql scripts /tmp/
RUN chmod +x /tmp/*.sh

# convert CRLF to LF in case Windows or VS Code changed it
RUN find . -type f \( -name "*.sql" -o -name "*.env" -o -name "*.sh" \) -exec sed -i 's/\r$//' {} \;

# switch to user mssql or the container will fail
USER mssql

# run initial setup scripts
RUN /bin/bash /tmp/start-sql.sh

###
#
#   final image: grab the good stuff, label
#   the image, and startup the sql instance
#
###

# copy the required changed files from "builder"
# and use it to start from scratch
FROM dbatools/mssqlbase
COPY --from=builder /var/opt/mssql /var/opt/mssql
COPY --from=builder /opt/mssql-tools/bin /opt/mssql-tools/bin
COPY --from=builder /tmp/post-entrypoint.sh /opt/mssql/bin/post-entrypoint.sh

# make a shared dir with the proper permissions
USER root
RUN  mkdir /shared; chown mssql /shared

# run a rootless container
USER root
# create a new database if env var is set
ENTRYPOINT /opt/mssql/bin/sqlservr & /opt/mssql/bin/post-entrypoint.sh

# Install PowerShell
RUN apt-get update && apt install -y powershell
# install git
RUN apt install -y git

# some cleanup
RUN apt-get autoremove -y \
    && apt-get clean -y

# things for ImportExcel

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends libgdiplus libc6-dev

ENV GIT_PROMPT_START='\033[1;36dbatools>\033[0m\033[0;33m\w\a\033[0m'

# Save command line history
RUN echo "export HISTFILE=/commandhistory/.bash_history" >> "/root/.bashrc" \
    && echo "export PROMPT_COMMAND='history -a'" >> "/root/.bashrc" \
    && mkdir -p /commandhistory \
    && touch /commandhistory/.bash_history

# Install Pester, 4.10.1
SHELL ["/usr/bin/pwsh", "-c"]
RUN $ErrorActionPreference='Stop'; Install-Module -Name Pester -Force -SkipPublisherCheck -MaximumVersion 4.10.1;

# Install dbatools prerelease
SHELL ["/usr/bin/pwsh", "-c"]
RUN $ErrorActionPreference='Stop'; Install-Module -Name dbatools -Force -AllowPreRelease;

# Install dbatools,PSFramework,dbachecks,posh-git,ImportExcel, Pansies
SHELL ["/usr/bin/pwsh", "-c"]
RUN $ErrorActionPreference='Stop'; Install-Module -Name dbatools,PSFramework,dbachecks,posh-git,Microsoft.PowerShell.ConsoleGuiTools,ImportExcel,Pansies,pshtml -Force -SkipPublisherCheck;

# set the dbatools config to not require encryption - change in SMO
SHELL ["/usr/bin/pwsh", "-c"]
RUN Set-DbatoolsConfig -Name sql.connection.trustcert -Value $true -passthru | Register-DbatoolsConfig; Set-DbatoolsConfig -Name sql.connection.encrypt -Value $false -passthru | Register-DbatoolsConfig

# Copy Profile
COPY Profile/profile.ps1 /root/.config/powershell/Microsoft.PowerShell_profile.ps1

