require "sterile"

module IsoDoc::Ietf
  class RfcConvert < ::IsoDoc::Convert
    def make_front(out, isoxml)
      info(isoxml, out)
      out.front do |front|
        title isoxml, front
        seriesinfo isoxml, front
        author isoxml, front
        date isoxml, front
        area isoxml, front
        workgroup isoxml, front
        keyword isoxml, front
        abstract isoxml, front
        note isoxml, front
        boilerplate isoxml, front
      end
    end

    def info(isoxml, out)
      @meta.keywords isoxml, out
      @meta.areas isoxml, out
      super
    end

    def title(isoxml, front)
      title = @meta.get[:doctitle] or return
      front.title title, **attr_code(abbrev: @meta.get[:docabbrev],
                                     ascii: @meta.get[:docascii])
    end

    def seriesinfo(isoxml, front)
      rfc_seriesinfo(isoxml, front) if @meta.get[:doctype] == "Rfc"
      id_seriesinfo(isoxml, front) if @meta.get[:doctype] == "Internet Draft"
    end

    def seriesinfo_attr(isoxml)
      attr_code(value: @meta.get[:docnumber],
                asciiValue: @meta.get[:docnumber]&.transliterate,
                status: @meta.get[:stage],
                stream: isoxml&.at(ns("//bibdata/series[@type = 'stream']/"\
                                      "title"))&.text)
    end

    def rfc_seriesinfo(isoxml, front)
      front.seriesInfo **seriesinfo_attr(isoxml).merge({name: "RFC",
                                                asciiName: "RFC"})
      i = isoxml&.at(ns("//bibdata/series[@type = 'intended']")) and
        front.seriesInfo **attr_code(name: "", 
                                     status: i&.at(ns("./title"))&.text,
                                     value: i&.at(ns("./number"))&.text)
    end

    def id_seriesinfo(isoxml, front)
      front.seriesInfo **seriesinfo_attr(isoxml).merge({name: "Internet-Draft",
                                                asciiName: "Internet-Draft"})
      i = isoxml&.at(ns("//bibdata/series[@type = 'intended']/title"))&.text and
        front.seriesInfo **attr_code(name: "", status: i)
    end

    def author(isoxml, front)
      isoxml.xpath(ns("//bibdata/contributor[role/type = 'editor' or "\
                      "role/type = 'author']")).each do |c|
        role = c.at(ns("./role/type")).text == "editor" ? "editor" : nil
        c.at("./organization") and org_author(c, role, front) or
          person_author(c, role, front)
      end
    end

    def person_author_attrs(c, role)
      return {} if c.nil?
      full = c&.at("./person/name/completeName")&.text
      ret = attr_code(role: role, fullname: full,
                      initials: c&.at("./person/name/initial")&.text,
                      surname: c&.at("./person/name/surname")&.text)
      full and ret.merge!(attr_code(
        asciiFullname: c&.at("./person/name/completeName")&.text&.transliterate,
        asciiInitials: c&.at("./person/name/initial")&.text&.transliterate,
        asciiSurname: c&.at("./person/name/surname")&.text&.transliterate))
      ret
    end

    def person_author(c, role, front)
      front.author **person_author_attrs(c.at("./person/name")) do |a|
        org = c.at(ns("./person/affiliation/organization")) and
          organization(org, a)
        address(c.xpath(ns(".//address")),
                c.at(ns(".//phone[not(@type = 'fax')]")),
                c.at(ns(".//phone[@type = 'fax']")),
                c.xpath(ns(".//email")), c.xpath(ns(".//uri")), a)
      end
    end

    def org_author(c, role, front)
      front.author **attr_code(role: role) do |a|
        organization(c.at(ns("./organization")), a)
        address(c.at(ns(".//address")),
                c.at(ns(".//phone[not(@type = 'fax')]")),
                c.at(ns(".//phone[@type = 'fax']")),
                c.xpath(ns(".//email")), c.xpath(ns(".//uri")), a)
      end
    end

    def organization(org, out)
      name = org.at(ns("./name"))&.text
      out.organization name, **attr_code(
        ascii: name&.transliterate,
        abbrev: org.at(ns("./abbreviation")))
    end

    def address(addr, phone, fax, email, uri, out)
      addr and postal(addr, out)
      phone and out.phone phone.text
      fax and out.facsimile fax.text
      email and email(email, out)
      uri and out.uri uri.text
    end

    def postal(addr, out)
      if line = addr.at(ns("./formattedAddress"))
        line.text.split(/\n/).each do |l|
          out.postalLine l, **attr_code(ascii: l.transliterate)
        end
      else
        postal_detailed(addr, out)
      end
    end

    def postal_detailed(addr, out)
      addr.xpath(ns("./street")).each do |s|
        out.street s.text, **attr_code(ascii: s.text.transliterate)
      end
      s = addr.at(ns("./city")) and
        out.city s.text, **attr_code(ascii: s.text.transliterate)
      s = addr.xpath(ns("./state")) and
        out.region s.text, **attr_code(ascii: s.text.transliterate)
      s = addr.xpath(ns("./country")) and
        out.country s.text, **attr_code(ascii: s.text.transliterate)
      s = addr.xpath(ns("./postcode")) and
        out.code s.text, **attr_code(ascii: s.text.transliterate)
    end

    def email(email, out)
      ascii = email.text.transliterate
      out.email email.text,
        **attr_code(ascii: ascii == email.text ? nil : ascii )
    end

    def date(isoxml, front)
      date = @meta.get[:publisheddate] || @meta.get[:circulateddate] || return
      date.gsub!(/T.*$/, "")
      attr = date_attr(date) || return
      front.date **attr_code(attr)
    end

    def date_attr(date)
      if date.length == 4 && date =~ /^\d\d\d\d$/ then { year: date }
      elsif date =~ /^\d\d\d\d-?\d\d$/
        matched = /^(?<year>\d\d\d\d)-(?<month>\d\d)$/.match date
        { month: Date::MONTHNAMES[(matched[:month]).to_i],
          year: matched[:year] }
      else
        begin
        d = Date.iso8601 date
        { day: d.day.to_s.gsub(/^0/, ""), year: d.year,
          month: Date::MONTHNAMES[d.month] }
        rescue
          nil
        end
      end
    end

    def area(isoxml, front)
      @meta.get[:areas].each do |w|
        front.area w
      end
    end

    def workgroup(isoxml, front)
      @meta.get[:wg].each do |w|
        front.workgroup w
      end
    end

    def keyword(isoxml, front)
      @meta.get[:keywords].each do |kw|
        front.keyword kw
      end
    end

    def abstract(isoxml, front)
      a = isoxml.at(ns("//preface/abstract | //preface/foreword")) || return
      front.abstract **attr_code(anchor: a["id"]) do |abs|
        a.children.reject { |c1| %w(title note).include? c1.name }.each do |c1|
          parse(c1, abs)
        end
      end
    end

    def note(isoxml, front)
      a = isoxml.at(ns("//preface/abstract/note | //preface/foreword/note")) || return
      front.note **attr_code(removeInRFC: a["removeInRFC"]) do |n|
        title = a.at(ns("./name")) and n.name do |t|
          title.children.each { |tt| parse(tt, t) }
        end
        a.children.reject { |c1| c1.name == "name" }.each do |c1|
          parse(c1, n)
        end
      end
    end

    def boilerplate(isoxml, front)
    end
  end
end
