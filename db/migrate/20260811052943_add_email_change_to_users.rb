class AddEmailChangeToUsers < ActiveRecord::Migration[8.1]
  def change
    # 仮メールアドレス
    add_column :users, :unconfirmed_email, :string
    # メールアドレス変更トークン
    add_column :users, :email_change_token, :string
    # メールアドレス変更トークン送信時間
    add_column :users, :email_change_token_sent_at, :datetime

    # メールアドレス変更トークンのインデックスを追加
    add_index :users, :email_change_token, unique: true
  end
end
