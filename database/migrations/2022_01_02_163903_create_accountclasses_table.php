<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateAccountclassesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('accountclass', function (Blueprint $table) {
            $table->bigIncrements('Window');
            $table->string('AccountClass', 45)->unique()->nullable();
            $table->tinyInteger('nostro')->default('0');
            $table->tinyInteger('balancesheet')->default('0');
            $table->tinyInteger('asset')->default('0');
            $table->tinyInteger('income')->default('0');
            $table->tinyInteger('matched')->default('0');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('accountclass');
    }
}
