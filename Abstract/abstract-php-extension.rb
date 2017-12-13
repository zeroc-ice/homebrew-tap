# **********************************************************************
#
# Copyright (c) 2003-2017 ZeroC, Inc. All rights reserved.
#
# This copy of Ice is licensed to you under the terms described in the
# ICE_LICENSE file included in this distribution.
#
# **********************************************************************

require 'tap'

phpTapDirectory = Tap.fetch("homebrew/homebrew-php").path

if File.exists?(phpTapDirectory)
    require File.join(phpTapDirectory, "Abstract", "abstract-php-extension")
else
    puts "PHP Homebrew tap missing. This is required to install PHP based formulae."
    puts "To install please run 'brew tap homebrew/homebrew-php'"

    class AbstractPhpExtension < Formula
        def self.init
        end
    end

    class AbstractPhp71Extension < AbstractPhpExtension
    end

    class AbstractPhp70Extension < AbstractPhpExtension
    end

    class AbstractPhp56Extension < AbstractPhpExtension
    end
end
