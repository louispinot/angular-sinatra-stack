class CreateCompanies < ActiveRecord::Migration
  def self.up

    # Jim wanted another option "empty" (email 2014-12-31), but it seems to be working with NULL values and a modified query, as well!
    execute <<-SQL
      DROP TYPE IF EXISTS company_segment;
      CREATE TYPE company_segment AS ENUM ('Enterprise', 'Freemium', 'Marketplaces', 'Ads/Leadgen', 'Ecommerce', 'SAAS', 'NA');
    SQL

    create_table :companies do |t|
      t.timestamps  :null => false

      t.belongs_to  :user                     # foreign key created at bottom!
      t.index       [:user_id]                # index for foreign key
      # every company has exactly one lifestage that we care about (this is usually the "last" one, but may deviate)
      t.integer     :current_lifestage        # actual PostgreSQL foreign key created in create_lifestage migration!


      # =========================================================================
      # historic, may be deleted after we get rid of MongoDB
      t.string      :old_mongoid              , :limit  => 24       # old BSON-Mongo IDs used for old companies
      t.index       [:old_mongoid]            , :unique => true

      t.column      :segment_type             , :company_segment    # company-segment type (ENUM) defined above
      t.index       [:segment_type]           # used as restriction when querying for peers

      t.string      :share_code
      t.string      :name
      t.string      :website
      t.string      :primary_currency         , :limit  => 3        # 3-letter ISO-4217 currency code


      # =========================================================================
      # Possible answers to 7 segmentation questions, flattened out:
      # FORM_PRIMARY_REVENUE_CHANNEL_CURRENT  (old webapp survey question)
      t.boolean     :monetiz_direct_standard
      t.boolean     :monetiz_direct_freemium
      t.boolean     :monetiz_indirect_standard
      t.boolean     :monetiz_indirect_two_sided

      # FORM_PRIMARY_REVENUE_CHANNEL_CURRENT  (old webapp survey question)
      t.boolean     :user_consumer
      t.boolean     :user_sme
      t.boolean     :user_enterprise
      t.boolean     :user_other

      # FORM_PRIMARY_REVENUE_CHANNEL_CURRENT  (old webapp survey question)
      t.boolean     :payer_consumer
      t.boolean     :payer_sme
      t.boolean     :payer_enterprise
      t.boolean     :payer_other

      # FORM_PRIMARY_REVENUE_CHANNEL_CURRENT  (old webapp survey question)
      t.boolean     :conv_visitor_user
      t.boolean     :conv_visitor_lead
      t.boolean     :conv_visitor_payer
      t.boolean     :conv_user_payer
      t.boolean     :conv_lead_payer
      t.boolean     :conv_other

      # FORM_PRIMARY_REVENUE_CHANNEL_CURRENT  (old webapp survey question)
      t.boolean     :life_day
      t.boolean     :life_week
      t.boolean     :life_month
      t.boolean     :life_quarter
      t.boolean     :life_year
      t.boolean     :life_two_years
      t.boolean     :life_three_years
      t.boolean     :life_four_years
      t.boolean     :life_five_years
      t.boolean     :life_more_five_years

      # FORM_PRIMARY_REVENUE_CHANNEL_CURRENT  (old webapp survey question)
      t.boolean     :acqu_affiliate
      t.boolean     :acqu_app_store
      t.boolean     :acqu_biz_dev
      t.boolean     :acqu_blogs
      t.boolean     :acqu_campaigns
      t.boolean     :acqu_conferences
      t.boolean     :acqu_direct_sales
      t.boolean     :acqu_domains
      t.boolean     :acqu_email
      t.boolean     :acqu_pr
      t.boolean     :acqu_radio
      t.boolean     :acqu_sem
      t.boolean     :acqu_seo
      t.boolean     :acqu_social_media
      t.boolean     :acqu_sponsorship
      t.boolean     :acqu_telemarketing
      t.boolean     :acqu_tv
      t.boolean     :acqu_viral_referral
      t.boolean     :acqu_widgets
      t.boolean     :acqu_word_of_mouth
      t.boolean     :acqu_other

      # FORM_PRIMARY_REVENUE_CHANNEL_CURRENT  (old webapp survey question)
      t.boolean     :rev_advertising
      t.boolean     :rev_consulting
      t.boolean     :rev_data
      t.boolean     :rev_hardware
      t.boolean     :rev_lead_generation
      t.boolean     :rev_license
      t.boolean     :rev_listing
      t.boolean     :rev_ownership
      t.boolean     :rev_rental
      t.boolean     :rev_sponsorship
      t.boolean     :rev_subscription
      t.boolean     :rev_transaction
      t.boolean     :rev_unit_selling
      t.boolean     :rev_virtual_goods
      # =========================================================================
    end #create_table do

    add_foreign_key :companies, :users  , :on_update => :cascade
  end #self.up()

  def self.down
    drop_table :companies
    execute <<-SQL
      DROP TYPE IF EXISTS company_segment;
    SQL
  end #self.down()

end #class CreateCompanies


