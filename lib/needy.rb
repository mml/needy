#!/usr/bin/env ruby

require 'rubygems'
require 'feed_tools'
require 'net/imap'
require 'time'

module Needy
  @@when = {}
  @@threads = []

  def imap_server host, args
    args = { :port => 143, :ssl  => false }.merge(args)
    @@server = Net::IMAP.new host, args[:port], args[:ssl]
    @@server.login args[:username], args[:password]
    @@server.select args[:folder] if args[:folder]
    thr { yield }
  end

  def gmail args, &block
    self.imap_server 'imap.gmail.com', { :port => 993,
                                         :ssl  => true,
                                         :folder => '[Gmail]/Sent Mail' }.merge(args), &block
  end

  def recipient abbrev, *others
    recips = [abbrev.to_s] + others.map(&:to_s)
    query = recips.map{|whom| "TO #{whom}"}.reduce{|memo,q| "OR #{q} #{memo}"}
    last_id = @@server.search(query).max
    set abbrev, Time.parse(@@server.fetch(last_id, 'envelope')[0].attr['ENVELOPE'].date)
  end

  def feed abbrev, url
    thr do
      feed = FeedTools::Feed.open(url)
      set abbrev, feed.updated || feed.items.map(&:published).max
    end
  end

  def git abbrev, dir, branch, &block
    thr do
      g = Needy::Git.new(dir, branch)
      yield(g) if block
      set abbrev, g.when
    end
  end

  def whens
    @@threads.each{|t| t.join}
    @@threads = []
    @@when
  end

  def thr &block
    @@threads.push(Thread.new(&block))
  end

  def set abbrev, val
    @@when[abbrev.to_s] = val
  end

  class Git
    attr_accessor :dir, :branch, :log_opt

    def initialize dir, branch
      self.dir = File.join File.expand_path(dir), '.git'
      self.branch = branch
      self.log_opt = ''
    end

    def git_cmd
      "git --git-dir=#{dir}"
    end

    def exec *args
      system("#{git_cmd} #{args.map(&:to_s).join(' ')}")
    end

    def when
      open "|#{git_cmd} log #{branch} #{log_opt} --pretty=%ct -n1" do |f|
        Time.at(f.gets.chomp.to_i)
      end
    end

    def author name
      self.log_opt += " --author=#{name}"
    end
  end
end
