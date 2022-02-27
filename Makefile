
all:
	$(NOOP)

run-bare-metal:
	ruby runner.rb

run-with-docker:
	docker run \
			--rm \
			-it \
			-v $(PWD)/:/usr/src/app \
			-w /usr/src/app \
			ruby:3.0.3 \
		  ruby runner.rb
