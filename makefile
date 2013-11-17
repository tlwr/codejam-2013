NAME=alpha
GIT=https://github.com

default: new

new:
	rhc app create -a $(NAME) -t ruby-1.9 && rhc cartridge add -a $(NAME) -c mysql-5.1

add:
	git remote add $(NAME) $(GIT)

deploy:
	git push -f $(NAME) master && rhc ssh $(NAME)

update:
	git pull && git push $(NAME) master && rhc ssh $(NAME)

over-ssh:
	less app-root/repo/log/production.log