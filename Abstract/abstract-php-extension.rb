# **********************************************************************
#
# Copyright (c) 2003-2017 ZeroC, Inc. All rights reserved.
#
# This copy of Ice is licensed to you under the terms described in the
# ICE_LICENSE file included in this distribution.
#
# **********************************************************************

require 'formula_assertions'
include ::Homebrew::Assertions

phpTapDirectory = shell_output("brew --repo homebrew/homebrew-php").strip

if File.exists?(phpTapDirectory)
    require File.join(phpTapDirectory, "Abstract", "abstract-php-extension")
else
    puts "PHP Homebrew tap missing. This is required to install ZeroC Ice PHP based packages."
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
