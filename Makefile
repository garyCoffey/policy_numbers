
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
			bundle install
		  bundle exec ruby runner.rb

run-tests: 
	docker run \
		--rm \
		-it \
		-v $(PWD)/:/usr/src/app \
		-w /usr/src/app \
		ruby:3.0.3 \
		bundle install
		bundle exec rspec ./spec