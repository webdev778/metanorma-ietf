require "spec_helper"
describe Asciidoctor::RFC::V3::Converter do
  it "renders a horizontal description list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [horizontal]
      A:: B
      C:: D
    INPUT
      <dl anchor="id" hanging="true">
      <dt>A</dt>
      <dd>B</dd>
      <dt>C</dt>
      <dd>D</dd>
      </dl>
    OUTPUT
  end
  it "renders a compact description list" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[id]]
      [compact]
      A:: B
      C:: D
    INPUT
      <dl anchor="id" spacing="compact">
      <dt>A</dt>
      <dd>B</dd>
      <dt>C</dt>
      <dd>D</dd>
      </dl>
    OUTPUT
  end
  it "renders nested description list/ulist" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      Dairy::
      * Milk
      * Eggs
      Bakery::
      * Bread
      Produce::
      * Bananas
    INPUT
      <dl>
      <dt>Dairy</dt>
      <dd>
      <ul>
      <li>Milk</li>
      <li>Eggs</li>
      </ul>
      </dd>
      <dt>Bakery</dt>
      <dd>
      <ul>
      <li>Bread</li>
      </ul>
      </dd>
      <dt>Produce</dt>
      <dd>
      <ul>
      <li>Bananas</li>
      </ul>
      </dd>
      </dl>
    OUTPUT
  end
  it "renders hybrid nested description list/ulist" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      Dairy:: That is,
      * Milk
      * Eggs
      Bakery:: Namely,
      * Bread
      Produce:: Viz.,
      * Bananas
    INPUT
      <dl>
      <dt>Dairy</dt>
      <dd><t>That is,</t>
      <ul>
      <li>Milk</li>
      <li>Eggs</li>
      </ul>
      </dd>
      <dt>Bakery</dt>
      <dd><t>Namely,</t>
      <ul>
      <li>Bread</li>
      </ul>
      </dd>
      <dt>Produce</dt>
      <dd><t>Viz.,</t>
      <ul>
      <li>Bananas</li>
      </ul>
      </dd>
      </dl>
    OUTPUT
  end
  it "permits multi paragraph list items" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author

      == Section 1
      Notes::  Note 1.
      +
      Note 2.
      +
      Note 3.
    INPUT
      <section anchor="_section_1" numbered="false">
         <name>Section 1</name>
         <dl>
         <dt>Notes</dt>
         <dd><t>Note 1.</t><t>Note 2.</t>
       <t>Note 3.</t></dd>
       </dl>
      </section>
    OUTPUT
  end
end
