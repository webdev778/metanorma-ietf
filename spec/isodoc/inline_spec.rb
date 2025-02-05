require "spec_helper"

RSpec.describe IsoDoc::Ietf::RfcConvert do
  it "processes inline formatting" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <em>A</em> <strong>B</strong> <sup>C</sup> <sub>D</sub> <tt>E</tt>
      <strike>F</strike> <smallcap>G</smallcap> <keyword>I</keyword> <bcp14>must</bcp14> <br/> <hr/>
      <bookmark id="H"/> <pagebreak/>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
        <em>A</em>
        <strong>B</strong>
        <sup>C</sup>
        <sub>D</sub>
        <tt>E</tt>
         F G I
        <bcp14>must</bcp14>
        <br/>
        <bookmark anchor='H'/>
      </t>
      </abstract></front><middle/><back/></rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes embedded inline formatting" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <em><strong>&lt;</strong></em> <tt><link target="B"/></tt> <xref target="_http_1_1" format="title" relative="#abc">Requirement <tt>/req/core/http</tt></xref> <eref type="inline" bibitemid="ISO712" citeas="ISO 712">Requirement <tt>/req/core/http</tt></eref> <eref type="inline" bibitemid="ISO712" displayFormat="of" citeas="ISO 712" relative="xyz"><locality type="section"><referenceFrom>3.1</referenceFrom></locality></eref>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
                     <em>
                       <strong>&lt;</strong>
                     </em>
                     <tt>
                       <eref target='B'/>
                     </tt>
                     <xref target='_http_1_1' format='title' relative='#abc'>
                       Requirement
                       <tt>/req/core/http</tt>
                     </xref>
                     <relref target='ISO712' section='' relative=''>
                       Requirement
                       <tt>/req/core/http</tt>
                     </relref>
                     <relref target='ISO712' section='3.1' displayFormat="of" relative="xyz"/>
                   </t>
      </abstract></front><middle/><back/></rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes index terms" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
       <preface><foreword>
       <p>D<index>
       <primary>A<sub>B</sub></primary>
       <secondary>A<sub>B</sub></secondary>
       <tertiary>A<sub>B</sub></tertiary>
       </index>.<index primary="true">
       <primary>D</primary></index></p>
       </foreword></preface>
       <sections>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{XML_HDR}
      <t>D
                  <iref item='AB' subitem='AB'/>
                  .
                  <iref item='D' primary="true"/></t>
      </abstract></front><middle/><back/></rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes inline images" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface><foreword>
        <p>
      <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
      </p>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
                     <artwork src='rice_images/rice_image1.png' title='titletxt' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
                   </t>
      </abstract></front><middle/><back/></rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes links" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <link target="http://example.com"/>
      <link target="http://example.com">example</link>
      <link target="http://example.com" alt="tip">example</link>
      <link target="mailto:fred@example.com"/>
      <link target="mailto:fred@example.com">mailto:fred@example.com</link>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
                     <eref target='http://example.com'/>
                     <eref target='http://example.com'>example</eref>
                     <eref target='http://example.com'>example</eref>
                     <eref target='mailto:fred@example.com'/>
                     <eref target='mailto:fred@example.com'>mailto:fred@example.com</eref>
                   </t>
      </abstract></front><middle/><back/></rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes unrecognised markup" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <barry fred="http://example.com">example</barry>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
      <t>
        <t>&lt;barry fred="http://example.com"&gt;example&lt;/barry&gt;</t>
      </t>
      </abstract></front><middle/><back/></rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes AsciiMath and MathML" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" xmlns:m="mathml">
      <preface><foreword>
      <p>
      <stem type="AsciiMath">&lt;A&gt;</stem>
      <stem type="MathML"><m:math><m:mrow><m:mi>X</m:mi></m:mrow></m:math></stem>
      <stem type="None">Latex?</stem>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
      $$ &lt;A&gt; $$
      $$ X $$
      $$ Latex? $$
      </t>
      </abstract></front><middle/><back/></rfc>
    OUTPUT
    expect((IsoDoc::Ietf::RfcConvert.new({}).convert("test", input, true).sub(
      /<html/, "<html xmlns:m='m'"
    ))).to be_equivalent_to xmlpp(output)
  end

  it "overrides AsciiMath delimiters" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <stem type="AsciiMath">A</stem>
      $$Hello$$$
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t> $$$$ A $$$$ $$Hello$$$ </t>
      </abstract></front><middle/><back/></rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "cross-references notes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
          <p>
          <xref target="N1">note</xref>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2">note</xref>
          <xref target="AN"/>
          <xref target="Anote1">note</xref>
          <xref target="Anote2"/>
          </p>
          </foreword>
          <introduction id="intro">
          <note id="N1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
      </note>
      <clause id="xyz"><title>Preparatory</title>
          <note id="N2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83d">These results are based on a study carried out on three different types of kernel.</p>
      </note>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope"><title>Scope</title>
          <note id="N">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
      <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <note id="note1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          <note id="note2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </note>
      <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <note id="AN">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </clause>
          <clause id="annex1b">
          <note id="Anote1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          <note id="Anote2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{XML_HDR}
               <t>
                 <xref target='N1'>note</xref>
                 <xref target='N2'/>
                 <xref target='N'/>
                 <xref target='note1'/>
                 <xref target='note2'>note</xref>
                 <xref target='AN'/>
                 <xref target='Anote1'>note</xref>
                 <xref target='Anote2'/>
               </t>
             </abstract>
           </front>
           <middle>
             <section anchor='intro'>
               <aside anchor='N1'>
                 <t>
                   NOTE: These results are based on a study carried out on three
                   different types of kernel.
                 </t>
               </aside>
               <section anchor='xyz'>
                 <name>Preparatory</name>
                 <aside anchor='N2'>
                   <t>
                     NOTE: These results are based on a study carried out on three
                     different types of kernel.
                   </t>
                 </aside>
               </section>
             </section>
             <section anchor='scope'>
               <name>Scope</name>
               <aside anchor='N'>
                 <t>
                   NOTE: These results are based on a study carried out on three
                   different types of kernel.
                 </t>
               </aside>
               <t>
                 <xref target='N'/>
               </t>
             </section>
             <section anchor='terms'/>
             <section anchor='widgets'>
               <name>Widgets</name>
               <section anchor='widgets1'>
                 <aside anchor='note1'>
                   <t>
                     NOTE 1: These results are based on a study carried out on three
                     different types of kernel.
                   </t>
                 </aside>
                 <aside anchor='note2'>
                   <t>
                     NOTE 2: These results are based on a study carried out on three
                     different types of kernel.
                   </t>
                 </aside>
                 <t>
                   <xref target='note1'/>
                   <xref target='note2'/>
                 </t>
               </section>
             </section>
           </middle>
           <back>
             <section anchor='annex1'>
               <section anchor='annex1a'>
                 <aside anchor='AN'>
                   <t>
                     NOTE: These results are based on a study carried out on three
                     different types of kernel.
                   </t>
                 </aside>
               </section>
               <section anchor='annex1b'>
                 <aside anchor='Anote1'>
                   <t>
                     NOTE 1: These results are based on a study carried out on three
                     different types of kernel.
                   </t>
                 </aside>
                 <aside anchor='Anote2'>
                   <t>
                     NOTE 2: These results are based on a study carried out on three
                     different types of kernel.
                   </t>
                 </aside>
               </section>
             </section>
           </back>
         </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes eref attributes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712" relative="#abc" displayFormat="of">A</stem>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
        <relref target='ISO712' section='' displayFormat='of' relative="#abc">A</relref>
      </t>
      </abstract></front><middle/>
      <back>
        <references anchor='_normative_references'>
          <name>Normative References</name>
          <reference anchor='ISO712'>
            <front>
        <title>Cereals and cereal products</title>
        <author>
          <organization abbrev='ISO'/>
        </author>
      </front>
      <refcontent>ISO 712</refcontent>
          </reference>
        </references>
      </back>
      </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes eref content" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"/>
          <eref type="inline" bibitemid="ISO712"/>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality>A</eref>
          <eref type="inline" bibitemid="ISO712"><locality type="whole"></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</eref>
          <eref type="inline" bibitemid="ISO712"><localityStack><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO712"><localityStack><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack><locality type="table"><referenceFrom>3</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><localityStack><locality type="anchor">><referenceFrom>1</referenceFrom></locality></localityStack>A</eref>
          <eref type="inline" bibitemid="ISO712"><localityStack><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="anchor"><referenceFrom>xyz</referenceFrom></locality></localityStack><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="table"><referenceFrom>1</referenceFrom></locality><locality type="anchor">><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="anchor">><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality><locality type="anchor">><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality><locality type="anchor">><referenceFrom>1</referenceFrom></locality>A</eref>
          <eref type="inline" bibitemid="ISO712"><locality type="whole"></locality><locality type="anchor">><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality><locality type="anchor">><referenceFrom>1</referenceFrom></locality></eref>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
        <relref target='ISO712' section='' relative=''/>
        <relref target='ISO712' section='' relative=''/>
        <relref target='ISO712' section='' relative=''/>
        <relref target='ISO712' section='' relative=''/>
        <relref target='ISO712' section='1' relative=''/>
        <relref target='ISO712' section='1' relative=''/>
        <relref target='ISO712' section='1.5' relative=''/>
        <relref target='ISO712' section='' relative=''>A</relref>
        <relref target='ISO712' section='' relative=''/>
        <relref target='ISO712' section='' relative=''/>
        <relref target='ISO712' section='' relative=''>A</relref>
        <relref target='ISO712' section='1; 3' relative=''/>
        <relref target='ISO712' section='1' relative=''/>
        <relref target='ISO712' section='' relative='1'>A</relref>
        <relref target='ISO712' section='1; 3' relative='xyz'/>
        <relref target='ISO712' section='1' relative='1'/>
      <relref target='ISO712' section='1' relative='1'/>
      <relref target='ISO712' section='1.5' relative='1'/>
      <relref target='ISO712' section='' relative='1'>A</relref>
      <relref target='ISO712' section='' relative='1'/>
      <relref target='ISO712' section='' relative='1'/>
      </t>
      </abstract></front><middle/>
      <back>
        <references anchor='_normative_references'>
          <name>Normative References</name>
          <reference anchor='ISO712'>
            <front>
        <title>Cereals and cereal products</title>
        <author>
          <organization abbrev='ISO'/>
        </author>
      </front>
      <refcontent>ISO 712</refcontent>
          </reference>
        </references>
      </back>
      </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes passthrough content" do
    FileUtils.rm_f "test.rfc.xml"
    IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", false)
      #{BLANK_HDR}
      <preface><foreword>
      <p>
      <passthrough>&lt;abc&gt;X &amp;gt; Y</passthrough>
      A
      <passthrough>&lt;/abc&gt;</passthrough>
      </p>
      </preface>
      </iso-standard>
    INPUT
    expect(File.read("test.rfc.xml")).to be_equivalent_to xmlpp(<<~"OUTPUT")
         <?xml version="1.0"?>
      <?rfc strict="yes"?>
      <?rfc compact="yes"?>
      <?rfc subcompact="no"?>
      <?rfc tocdepth="4"?>
      <?rfc symrefs="yes"?>
      <?rfc sortrefs="yes"?>
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" category="std" ipr="trust200902" submissionType="IETF" xml:lang="en" version="3" >
        <front>
          <title>Document title</title>
          <seriesInfo value="" status="Published" stream="IETF" name="Internet-Draft" asciiName="Internet-Draft"></seriesInfo>
          <abstract>
      <t>
      <abc>X &gt; Y
      A
      </abc>
      </t>
      </abstract>
        </front>
        <middle></middle>
        <back></back>
      </rfc>
    OUTPUT
  end

  it "processes concept markup" do
    input = <<~INPUT
             <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p>
          <ul>
          <li><concept><refterm>term</refterm>
              <xref target='clause1'/>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>term</renderterm>
              <xref target='clause1'/>
            </concept></li>
          <li><concept><refterm>term</refterm>
              <renderterm>w[o]rd</renderterm>
              <xref target='clause1'>Clause #1</xref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>term</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712"/>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">The Aforementioned Citation</eref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
                <locality type='figure'>
                  <referenceFrom>a</referenceFrom>
                </locality>
              </eref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
              <localityStack>
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack>
              <localityStack>
                <locality type='figure'>
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>
              </eref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
              <localityStack>
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack>
              <localityStack>
                <locality type='figure'>
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>
              The Aforementioned Citation
              </eref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <termref base='IEV' target='135-13-13'/>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <termref base='IEV' target='135-13-13'>The IEV database</termref>
            </concept></li>
            </ul>
          </p>
          </foreword></preface>
          <sections>
          <clause id="clause1"><title>Clause 1</title></clause>
          </sections>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version='1.0'?>
      <?rfc strict="yes"?>
      <?rfc compact="yes"?>
      <?rfc subcompact="no"?>
      <?rfc tocdepth="4"?>
      <?rfc symrefs="yes"?>
      <?rfc sortrefs="yes"?>
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' category='std' submissionType='IETF' version='3'>
        <front>
          <seriesInfo value='' name='RFC' asciiName='RFC'/>
          <abstract>
            <t>
              <ul>
                <li>
                  [term defined in
                  <xref target='clause1'/>
                  ]
                </li>
                <li>
                  <em>term</em>
                   [term defined in
                  <xref target='clause1'/>
                  ]
                </li>
                <li>
                  <em>w[o]rd</em>
                   [term defined in
                  <xref target='clause1'>Clause #1</xref>
                  ]
                </li>
                <li>
                  <em>term</em>
                   [term defined in
                  <relref target='ISO712' section='' relative=''/>
                  ]
                </li>
                <li>
                  <em>word</em>
                   [term defined in
                  <relref target='ISO712' section='' relative=''>The Aforementioned Citation</relref>
                  ]
                </li>
                <li>
                  <em>word</em>
                   [term defined in
                  <relref target='ISO712' section='3.1' relative=''> </relref>
                  ]
                </li>
                <li>
                  <em>word</em>
                   [term defined in
                  <relref target='ISO712' section='3.1' relative=''> </relref>
                  ]
                </li>
                <li>
                  <em>word</em>
                   [term defined in
                  <relref target='ISO712' section='3.1' relative=''> The Aforementioned Citation </relref>
                  ]
                </li>
                <li>
                  <em>word</em>
                   [term defined in Termbase IEV, term ID 135-13-13]
                </li>
                <li>
                  <em>word</em>
                   [term defined in The IEV database]
                </li>
              </ul>
            </t>
          </abstract>
        </front>
        <middle>
          <section anchor='clause1'>
            <name>Clause 1</name>
          </section>
        </middle>
        <back>
          <references anchor='_normative_references'>
            <name>Normative References</name>
            <t>
              The following documents are referred to in the text in such a way that
              some or all of their content constitutes requirements of this document.
              For dated references, only the edition cited applies. For undated
              references, the latest edition of the referenced document (including any
              amendments) applies.
            </t>
            <reference anchor='ISO712'>
              <front>
                <title>Cereals or cereal products</title>
                <author>
                  <organization ascii='International Organization for Standardization'>International Organization for Standardization</organization>
                </author>
              </front>
              <refcontent>ISO 712</refcontent>
            </reference>
          </references>
        </back>
      </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end
end
