# 18F Hub - Docs & connections between team members, projects, and skill sets
#
# Written in 2014 by Mike Bland (michael.bland@gsa.gov)
# on behalf of the 18F team, part of the US General Services Administration:
# https://18f.gsa.gov/
#
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication along
# with this software. If not, see
# <https://creativecommons.org/publicdomain/zero/1.0/>.
#
# @author Mike Bland (michael.bland@gsa.gov)

require 'jekyll-assets'

module Hub

  # Contains Hub-specific Liquid filters.
  module Filters

    def img_file_path(name, site)
      File.join(site['team_img_dir'], "#{name}.jpg")
    end

    def photo_exists(name, site, alt)
      if alt
        names = [name, alt]
      else
        names = [name]
      end
      names.each do |name|
        if photo_exists_in(name, site) || photo_exists_at(name, site)
          return true
        end
      end
      return false
    end

    def photo_exists_in(name, site)
      File.exists? img_file_path(name, site)
    end

    def photo_exists_at(name,site)
      uri = URI("#{site['photo_repository_url']}#{name}.jpg")
      res = Net::HTTP.get_response(uri)
      res.code == "200"
    end

    # URL of team member's photo, or to the substitute image
    # when their photo is missing
    def photo_or_placeholder(name, site, alt_name)
      if alt_name
        names = [name,alt_name]
      else
        names = [name]
      end

      base = site['baseurl'] || ''
      names.each do |name, index|
        if photo_exists_in(name, site)
          return File.join(base, img_file_path(name, site))
        end
        if photo_exists_at(name, site)
          return "#{site['photo_repository_url']}#{name}.jpg"
        end
      end
      File.join(base, site['team_img_dir'], site['missing_team_member_img'])
    end

    # Returns a canonicalized, URL-friendly substitute for an arbitrary string.
    # +s+:: string to canonicalize
    def canonicalize(s)
      Canonicalizer.canonicalize s
    end

    # Because checking class types in Jekyll does not seem to work,
    # we need a filter that returns it
    def class_name(data)
      data.class.name
    end
  end
end

Liquid::Template.register_filter(Hub::Filters)
