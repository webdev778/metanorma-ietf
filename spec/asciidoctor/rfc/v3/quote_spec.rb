require "spec_helper"

xdescribe Asciidoctor::RFC::V3::Converter do
  it "renders a verse" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[verse-id]]
      [verse, attribution="verse attribution", citetitle="http://www.foo.bar"]
      Text
    INPUT
      <blockquote anchor="verse-id" quotedFrom="verse attribution" cite="http://www.foo.bar">
      Text
      </blockquote>
    OUTPUT
  end

  it "renders a verse" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[verse-id]]
      [quote, attribution="verse attribution", citetitle="http://www.foo.bar"]
      Text
    INPUT
      <blockquote anchor="verse-id" quotedFrom="verse attribution" cite="http://www.foo.bar">
      Text
      </blockquote>
    OUTPUT
  end

end
