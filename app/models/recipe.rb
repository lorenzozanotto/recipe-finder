class Recipe < ActiveRecord::Base
	searchkick

	has_many :ingredients
	has_many :directions
	belongs_to :user

	accepts_nested_attributes_for :ingredients, reject_if: proc { |attributes| attributes['name'].blank? }, allow_destroy: true
 	accepts_nested_attributes_for :directions, reject_if: proc { |attributes| attributes['step'].blank? }, allow_destroy: true


	has_attached_file :image, styles: { medium: "400x400#" }
	validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
	validates :title, :description, :image, presence: true

	def search_data
  		attributes.merge(
    		ingredient: ingredients.map(&:name)
  		)
	end

end
