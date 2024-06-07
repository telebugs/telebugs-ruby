# frozen_string_literal: true

require "test_helper"

class TestBacktrace < Minitest::Test
  def setup
    @error = RuntimeError.new
  end

  def test_parse_unix_backtrace
    @error.set_backtrace([
      "/home/kyrylo/code/telebugs/ruby/spec/spec_helper.rb:23:in `<top (required)>'",
      "/opt/rubies/ruby-2.2.2/lib/ruby/2.2.0/rubygems/core_ext/kernel_require.rb:54:in `require'",
      "/opt/rubies/ruby-2.2.2/lib/ruby/2.2.0/rubygems/core_ext/kernel_require.rb:54:in `require'",
      "/home/kyrylo/code/telebugs/ruby/spec/telebugs_spec.rb:1:in `<top (required)>'",
      "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/configuration.rb:1327:in `load'",
      "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/configuration.rb:1327:in `block in load_spec_files'",
      "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/configuration.rb:1325:in `each'",
      "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/configuration.rb:1325:in `load_spec_files'",
      "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/runner.rb:102:in `setup'",
      "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/runner.rb:88:in `run'",
      "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/runner.rb:73:in `run'",
      "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/runner.rb:41:in `invoke'",
      "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/exe/rspec:4:in `<main>'"
    ])

    parsed = [
      {file: "/home/kyrylo/code/telebugs/ruby/spec/spec_helper.rb", line: 23, function: "<top (required)>"},
      {file: "/opt/rubies/ruby-2.2.2/lib/ruby/2.2.0/rubygems/core_ext/kernel_require.rb", line: 54, function: "require"},
      {file: "/opt/rubies/ruby-2.2.2/lib/ruby/2.2.0/rubygems/core_ext/kernel_require.rb", line: 54, function: "require"},
      {file: "/home/kyrylo/code/telebugs/ruby/spec/telebugs_spec.rb", line: 1, function: "<top (required)>"},
      {file: "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/configuration.rb", line: 1327, function: "load"},
      {file: "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/configuration.rb", line: 1327, function: "block in load_spec_files"},
      {file: "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/configuration.rb", line: 1325, function: "each"},
      {file: "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/configuration.rb", line: 1325, function: "load_spec_files"},
      {file: "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/runner.rb", line: 102, function: "setup"},
      {file: "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/runner.rb", line: 88, function: "run"},
      {file: "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/runner.rb", line: 73, function: "run"},
      {file: "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/runner.rb", line: 41, function: "invoke"},
      {file: "/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/exe/rspec", line: 4, function: "<main>"}
    ]

    assert_equal parsed, Telebugs::Backtrace.parse(@error)
  end

  def test_parse_windows_backtrace
    @error.set_backtrace([
      "C:/Program Files/Server/app/models/user.rb:13:in `magic'",
      "C:/Program Files/Server/app/controllers/users_controller.rb:8:in `index'"
    ])

    parsed = [
      {file: "C:/Program Files/Server/app/models/user.rb", line: 13, function: "magic"},
      {file: "C:/Program Files/Server/app/controllers/users_controller.rb", line: 8, function: "index"}
    ]
    assert_equal parsed, Telebugs::Backtrace.parse(@error)
  end

  def test_parse_jruby_java_backtrace
    @error.set_backtrace([
      "org.jruby.java.invokers.InstanceMethodInvoker.call(InstanceMethodInvoker.java:26)",
      "org.jruby.ir.interpreter.Interpreter.INTERPRET_EVAL(Interpreter.java:126)",
      "org.jruby.RubyKernel$INVOKER$s$0$3$eval19.call(RubyKernel$INVOKER$s$0$3$eval19.gen)",
      "org.jruby.RubyKernel$INVOKER$s$0$0$loop.call(RubyKernel$INVOKER$s$0$0$loop.gen)",
      "org.jruby.runtime.IRBlockBody.doYield(IRBlockBody.java:139)",
      "org.jruby.RubyKernel$INVOKER$s$rbCatch19.call(RubyKernel$INVOKER$s$rbCatch19.gen)",
      "opt.rubies.jruby_minus_9_dot_0_dot_0_dot_0.bin.irb.invokeOther4:start(/opt/rubies/jruby-9.0.0.0/bin/irb)",
      "opt.rubies.jruby_minus_9_dot_0_dot_0_dot_0.bin.irb.RUBY$script(/opt/rubies/jruby-9.0.0.0/bin/irb:13)",
      "org.jruby.ir.Compiler$1.load(Compiler.java:111)",
      "org.jruby.Main.run(Main.java:225)",
      "org.jruby.Main.main(Main.java:197)"
    ])

    parsed = [
      {file: "InstanceMethodInvoker.java", line: 26, function: "org.jruby.java.invokers.InstanceMethodInvoker.call"},
      {file: "Interpreter.java", line: 126, function: "org.jruby.ir.interpreter.Interpreter.INTERPRET_EVAL"},
      {file: "RubyKernel$INVOKER$s$0$3$eval19.gen", line: nil, function: "org.jruby.RubyKernel$INVOKER$s$0$3$eval19.call"},
      {file: "RubyKernel$INVOKER$s$0$0$loop.gen", line: nil, function: "org.jruby.RubyKernel$INVOKER$s$0$0$loop.call"},
      {file: "IRBlockBody.java", line: 139, function: "org.jruby.runtime.IRBlockBody.doYield"},
      {file: "RubyKernel$INVOKER$s$rbCatch19.gen", line: nil, function: "org.jruby.RubyKernel$INVOKER$s$rbCatch19.call"},
      {file: "/opt/rubies/jruby-9.0.0.0/bin/irb", line: nil, function: "opt.rubies.jruby_minus_9_dot_0_dot_0_dot_0.bin.irb.invokeOther4:start"},
      {file: "/opt/rubies/jruby-9.0.0.0/bin/irb", line: 13, function: "opt.rubies.jruby_minus_9_dot_0_dot_0_dot_0.bin.irb.RUBY$script"},
      {file: "Compiler.java", line: 111, function: "org.jruby.ir.Compiler$1.load"},
      {file: "Main.java", line: 225, function: "org.jruby.Main.run"},
      {file: "Main.java", line: 197, function: "org.jruby.Main.main"}
    ]
    assert_equal parsed, Telebugs::Backtrace.parse(@error)
  end

  def test_parse_jruby_classloader_backtrace
    @error.set_backtrace([
      "uri_3a_classloader_3a_.META_minus_INF.jruby_dot_home.lib.ruby.stdlib.net.protocol.rbuf_fill(uri:classloader:/META-INF/jruby.home/lib/ruby/stdlib/net/protocol.rb:158)",
      "bin.processors.image_uploader.block in make_streams(bin/processors/image_uploader.rb:21)",
      "uri_3a_classloader_3a_.gems.faye_minus_websocket_minus_0_dot_10_dot_5.lib.faye.websocket.api.invokeOther13:dispatch_event(uri_3a_classloader_3a_/gems/faye_minus_websocket_minus_0_dot_10_dot_5/lib/faye/websocket/uri:classloader:/gems/faye-websocket-0.10.5/lib/faye/websocket/api.rb:109)",
      "tmp.jruby9022301782566983632extract.$dot.META_minus_INF.rails.file(/tmp/jruby9022301782566983632extract/./META-INF/rails.rb:13)"
    ])

    parsed = [
      {file: "uri:classloader:/META-INF/jruby.home/lib/ruby/stdlib/net/protocol.rb", line: 158, function: "uri_3a_classloader_3a_.META_minus_INF.jruby_dot_home.lib.ruby.stdlib.net.protocol.rbuf_fill"},
      {file: "bin/processors/image_uploader.rb", line: 21, function: "bin.processors.image_uploader.block in make_streams"},
      {file: "uri_3a_classloader_3a_/gems/faye_minus_websocket_minus_0_dot_10_dot_5/lib/faye/websocket/uri:classloader:/gems/faye-websocket-0.10.5/lib/faye/websocket/api.rb", line: 109, function: "uri_3a_classloader_3a_.gems.faye_minus_websocket_minus_0_dot_10_dot_5.lib.faye.websocket.api.invokeOther13:dispatch_event"},
      {file: "/tmp/jruby9022301782566983632extract/./META-INF/rails.rb", line: 13, function: "tmp.jruby9022301782566983632extract.$dot.META_minus_INF.rails.file"}
    ]
    assert_equal parsed, Telebugs::Backtrace.parse(@error)
  end

  def test_parse_jruby_nonthrowable_backtrace
    @error.set_backtrace([
      "org.postgresql.core.v3.ConnectionFactoryImpl.openConnectionImpl(org/postgresql/core/v3/ConnectionFactoryImpl.java:257)",
      "org.postgresql.core.ConnectionFactory.openConnection(org/postgresql/core/ConnectionFactory.java:65)",
      "org.postgresql.jdbc2.AbstractJdbc2Connection.<init>(org/postgresql/jdbc2/AbstractJdbc2Connection.java:149)"
    ])

    parsed = [
      {file: "org/postgresql/core/v3/ConnectionFactoryImpl.java", line: 257, function: "org.postgresql.core.v3.ConnectionFactoryImpl.openConnectionImpl"},
      {file: "org/postgresql/core/ConnectionFactory.java", line: 65, function: "org.postgresql.core.ConnectionFactory.openConnection"},
      {file: "org/postgresql/jdbc2/AbstractJdbc2Connection.java", line: 149, function: "org.postgresql.jdbc2.AbstractJdbc2Connection.<init>"}
    ]
    assert_equal parsed, Telebugs::Backtrace.parse(@error)
  end

  def test_parse_generic_backtrace_without_a_func
    @error.set_backtrace([
      "/home/bingo/bango/assets/stylesheets/error_pages.scss:139:in `animation'",
      "/home/bingo/bango/assets/stylesheets/error_pages.scss:139",
      "/home/bingo/.gem/ruby/2.2.2/gems/sass-3.4.20/lib/sass/tree/visitors/perform.rb:349:in `block in visit_mixin'"
    ])

    parsed = [
      {file: "/home/bingo/bango/assets/stylesheets/error_pages.scss", line: 139, function: "animation"},
      {file: "/home/bingo/bango/assets/stylesheets/error_pages.scss", line: 139, function: nil},
      {file: "/home/bingo/.gem/ruby/2.2.2/gems/sass-3.4.20/lib/sass/tree/visitors/perform.rb", line: 349, function: "block in visit_mixin"}
    ]
    assert_equal parsed, Telebugs::Backtrace.parse(@error)
  end

  def test_parse_generic_backtrace_without_a_line_number
    @error.set_backtrace([
      "/Users/grammakov/repositories/weintervene/config.ru:in `new'"
    ])

    parsed = [
      {file: "/Users/grammakov/repositories/weintervene/config.ru", line: nil, function: "new"}
    ]
    assert_equal parsed, Telebugs::Backtrace.parse(@error)
  end

  def test_parse_unsupported_backtrace
    @error.set_backtrace([
      "a b c 1 23 321 .rb"
    ])

    parsed = [
      file: nil, line: nil, function: "a b c 1 23 321 .rb"
    ]
    assert_equal parsed, Telebugs::Backtrace.parse(@error)
  end

  def test_parse_backtrace_with_an_empty_function
    @error.set_backtrace([
      "/telebugs-ruby/vendor/jruby/1.9/gems/rspec-core-3.4.1/exe/rspec:3:in `'"
    ])

    parsed = [
      {file: "/telebugs-ruby/vendor/jruby/1.9/gems/rspec-core-3.4.1/exe/rspec", line: 3, function: ""}
    ]
    assert_equal parsed, Telebugs::Backtrace.parse(@error)
  end

  def test_parse_oracle_backtrace
    @error = OCIError.new
    @error.set_backtrace([
      'ORA-06512: at "STORE.LI_LICENSES_PACK", line 1945',
      'ORA-06512: at "ACTIVATION.LI_ACT_LICENSES_PACK", line 101',
      "ORA-06512: at line 2",
      "from stmt.c:243:in oci8lib_220.bundle"
    ])

    parsed = [
      {file: nil, line: 1945, function: "STORE.LI_LICENSES_PACK"},
      {file: nil, line: 101, function: "ACTIVATION.LI_ACT_LICENSES_PACK"},
      {file: nil, line: 2, function: nil},
      {file: "stmt.c", line: 243, function: "oci8lib_220.bundle"}
    ]
    assert_equal parsed, Telebugs::Backtrace.parse(@error)
  end

  def test_parse_execjs_backtrace
    @error = ExecJS::RuntimeError.new
    @error.set_backtrace([
      "compile ((execjs):6692:19)",
      "eval (<anonymous>:1:10)",
      "(execjs):6703:8",
      "require../helpers.exports ((execjs):1:102)",
      "Object.<anonymous> ((execjs):1:120)",
      "Object.Module._extensions..js (module.js:550:10)",
      "bootstrap_node.js:467:3",
      "/opt/rubies/ruby-2.3.1/lib/ruby/2.3.0/benchmark.rb:308:in `realtime'"
    ])

    parsed = [
      {file: "(execjs)", line: 6692, function: "compile"},
      {file: "<anonymous>", line: 1, function: "eval"},
      {file: "(execjs)", line: 6703, function: ""},
      {file: "(execjs)", line: 1, function: "require../helpers.exports"},
      {file: "(execjs)", line: 1, function: "Object.<anonymous>"},
      {file: "module.js", line: 550, function: "Object.Module._extensions..js"},
      {file: "bootstrap_node.js", line: 467, function: ""},
      {file: "/opt/rubies/ruby-2.3.1/lib/ruby/2.3.0/benchmark.rb", line: 308, function: "realtime"}
    ]
    assert_equal parsed, Telebugs::Backtrace.parse(@error)
  end
end
