<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class UpdateCashbook1ForeignKey extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('cashbook1', function (Blueprint $table) {
            $table->bigInteger('creditFK')->unsigned()->change();
            $table->foreign('creditFK')->references('AccountID')->on('accounts');
            $table->bigInteger('DebitFK')->unsigned()->change();
            $table->foreign('DebitFK')->references('AccountID')->on('accounts');
            $table->bigInteger('segmentcredit')->unsigned()->change();
            $table->foreign('segmentcredit')->references('SegmentID')->on('segments');
            $table->bigInteger('segmentdebit')->unsigned()->change();
            $table->foreign('segmentdebit')->references('SegmentID')->on('segments');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        //
    }
}
