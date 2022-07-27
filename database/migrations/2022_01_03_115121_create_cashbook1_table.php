<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCashbook1Table extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('cashbook1', function (Blueprint $table) {
            $table->bigIncrements('cashID');
            $table->decimal('Amount', 15, 2)->unique();
            $table->decimal('Cat', 5, 2)->nullable();
            $table->string('FullCat', 15)->nullable();
            $table->text('Credit')->nullable();
            $table->text('Debit')->nullable();
            $table->text('Details')->nullable();
            $table->integer('creditFK')->unsigned();
            $table->integer('DebitFK')->unsigned();
            $table->integer('segmentcredit')->unsigned()->nullable();
            $table->integer('segmentdebit')->unsigned()->nullable();
            $table->string('segment',25)->nullable();
            $table->integer('cheque')->unsigned()->nullable();
            $table->time('transactiontime')->nullable();
            $table->decimal('Numbercredited', 15, 3)->unsigned()->default('0.000');
            $table->decimal('Numberdebited', 15, 3)->unsigned()->default('0.000');
            $table->decimal('commission', 8, 2)->unsigned()->nullable();
            $table->timestamp('tstamp')->useCurrent();
            $table->decimal('fx', 7, 4)->unsigned()->default('1.0000');
            $table->string('Status', 1)->nullable()->default('U');
            $table->string('Autoreverse', 1)->nullable();
            $table->string('User', 35)->nullable();
            

        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('cashbook1');
    }
}
