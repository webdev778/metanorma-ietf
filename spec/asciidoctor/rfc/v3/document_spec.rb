require "spec_helper"
require "byebug"
describe Asciidoctor::RFC::V3::Converter do
  it "renders the minimal document w/ default values" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders all document attributes" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author
      :abbrev: abbrev
      :ipr: ipr_value
      :consensus: false
      :obsoletes: 1, 2
      :updates: 10, 11
      :index-include: index_include_value
      :ipr-extract: ipr_extract_value
      :sort-refs: true
      :sym-refs: false
      :toc-include: false
      :toc-depth: 2
      :submission-type: IRTF
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc ipr="ipr_value" obsoletes="1, 2" updates="10, 11" prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IRTF" indexInclude="index_include_value" iprExtract="ipr_extract_value" sortRefs="true" symRefs="false" tocInclude="false" tocDepth="2">
      <front>
      <title abbrev="abbrev">Document title</title>
      <author fullname="Author">
      </author>
      </front><middle>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders back matter" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      :docName:
      Author

      [appendix]
      == Appendix
      Lipsum.
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <rfc prepTime="1970-01-01T00:00:00Z"
                version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      </front><middle>
      </middle><back>
      <section anchor="_appendix" numbered="false">
      <name>Appendix</name>
      <t>Lipsum.</t>
      </section>
      </back>
      </rfc>
    OUTPUT
  end
end
