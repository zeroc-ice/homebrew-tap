# **********************************************************************
#
# Copyright (c) 2003-2016 ZeroC, Inc. All rights reserved.
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
    puts "php Homebrew tap missing. You need to install the hombrew-php tap. Please run 'brew tap homebrew/homebrew-php'"
    exit(1)
end
