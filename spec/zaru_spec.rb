# encoding: utf-8
require 'zaru'

RSpec.describe Zaru do
  describe '#normalize' do
    let(:surrounding_whitespace) { ['a', ' a', 'a ', ' a ', "\ta    \n"] }
    let(:inner_whitespace) { ['x x', 'x  x', 'x   x', "x\tx", "x\r\nx", "x \n\tx"] }

    it 'strips surrounding whitespace' do
      surrounding_whitespace.each do |name|
        expect(Zaru.sanitize!(name)).to eq('a')
      end
    end

    it 'collapses inner whitespace to a single space' do
      inner_whitespace.each do |name|
        expect(Zaru.sanitize!(name)).to eq('x x')
      end
    end

    it 'collapses inner whitespace to the whitespace param' do
      surrounding_whitespace.each do |name|
        expect(Zaru.sanitize!(name, whitespace: '_')).to eq('a')
      end

      inner_whitespace.each do |name|
        expect(Zaru.sanitize!(name, whitespace: '_')).to eq('x_x')
      end
    end
  end

  describe '#truncate' do
    let(:name) { 'a'*500 }

    it 'truncates long names' do
      expect(Zaru.sanitize!(name).length).to eq(255)
    end

    it 'does not truncate short names' do
      expect(Zaru.sanitize!('aaa').length).to eq(3)

      expect(Zaru.sanitize!('a' + ' '*500 + 'a').length).to eq(3)
    end

    it 'subtracts padding from the length' do
      expect(Zaru.sanitize!(name, padding: 10).length).to eq(245)
    end

    it 'allows configurable lengths' do
      expect(Zaru.sanitize!(name, length: 200).length).to eq(200)

      expect(Zaru.sanitize!(name, length: 205, padding: 5).length).to eq(200)
    end

    it 'only allows positive lengths' do
      pending('Not yet implemented.')
      fail
      expect(Zaru.sanitize!(name, length: 0).length).to eq(255)

      expect(Zaru.sanitize!(name, length: -10).length).to eq(255)

      expect(Zaru.sanitize!(name, length: 10, padding: 10).length).to eq(255)

      expect(Zaru.sanitize!(name, length: 5, padding: 10).length).to eq(255)

      expect(Zaru.sanitize!(name, length: -10, padding: 10).length).to eq(255)
    end
  end

  describe '#sanitize' do
    let(:bad_chars) { "`!@$*()[]{}<>?|:;'/\"\\".chars }
    let(:ascii_control_chars) { ["\x01", "\x12", "\x1f"] }
    let(:leading_dashes) { ['a', '-a', '---a', '- a', '- -a', '- - a'] }

    it 'does not change good names' do
      expect(Zaru.sanitize!('abcdef')).to eq("abcdef")
    end

    it 'removes blacklisted characters' do
      bad_chars.each do |char|
        expect(Zaru.sanitize!("a#{char}")).to eq('a')
        expect(Zaru.sanitize!("#{char}a")).to eq('a')
        expect(Zaru.sanitize!("a#{char}a")).to eq('aa')
      end

      ascii_control_chars.each do |char|
        expect(Zaru.sanitize!("a#{char}")).to eq('a')
        expect(Zaru.sanitize!("#{char}a")).to eq('a')
        expect(Zaru.sanitize!("a#{char}a")).to eq('aa')
      end
    end

    it 'replaces blacklisted characters with the replacement param' do
      bad_chars.each do |char|
        expect(Zaru.sanitize!("a#{char}", replace: '_')).to eq('a_')
        expect(Zaru.sanitize!("#{char}a", replace: '_')).to eq('_a')
        expect(Zaru.sanitize!("a#{char}a", replace: '_')).to eq('a_a')
      end

      ascii_control_chars.each do |char|
        expect(Zaru.sanitize!("a#{char}", replace: '_')).to eq('a_')
        expect(Zaru.sanitize!("#{char}a", replace: '_')).to eq('_a')
        expect(Zaru.sanitize!("a#{char}a", replace: '_')).to eq('a_a')
      end
    end

    it 'does not remove unicode' do
      expect(Zaru.sanitize!("笊, ざる.pdf")).to eq("笊, ざる.pdf")

      expect(Zaru.sanitize!('  what\\ēver//wëird:user:înput: ')).to eq("whatēverwëirduserînput")
    end

    it 'removes leading dashes from filenames' do
      leading_dashes.each do |name|
        expect(Zaru.sanitize!(name)).to eq('a')
      end
    end

    it 'does not allow windows reserved filenames' do
      expect(Zaru.sanitize!('CON')).to eq("file")
      expect(Zaru.sanitize!('lpt1 ')).to eq("file")
      expect(Zaru.sanitize!('com4|')).to eq("file")
      expect(Zaru.sanitize!(' aux')).to eq("file")
      expect(Zaru.sanitize!(" LpT\x122")).to eq("file")
      expect(Zaru.sanitize!('COM10')).to eq("COM10")
    end

    it 'does not allow filenames to be blank' do
      bad_chars.each do |char|
        expect(Zaru.sanitize!(char)).to eq('file')
      end

      ascii_control_chars.each do |char|
        expect(Zaru.sanitize!(char)).to eq('file')
      end
    end
  end
end
