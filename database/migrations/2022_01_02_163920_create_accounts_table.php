<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateAccountsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('accounts', function (Blueprint $table) {
            $table->bigIncrements('AccountID');
            $table->string('AccountName', 45)->unique()->nullable();
            $table->integer('DefaultSegment')->nullable();
            $table->string('bloomberg', 75)->nullable();
            $table->string('epic', 20)->nullable();
            $table->timestamp('tstampaccounts', 0)->useCurrent();
            $table->string('currency', 3)->default('£')->nullable();
            $table->string('Taxcountry', 2)->default('GB')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('accounts');
    }
}
