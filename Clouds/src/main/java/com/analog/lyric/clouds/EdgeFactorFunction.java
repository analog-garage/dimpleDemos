package com.analog.lyric.clouds;

import com.analog.lyric.dimple.factorfunctions.core.FactorFunction;
import com.analog.lyric.dimple.factorfunctions.core.FactorFunctionUtilities;
import com.analog.lyric.dimple.model.values.Value;

public class EdgeFactorFunction extends FactorFunction
{

	public EdgeFactorFunction()
	{
		super("Edge Factor Function");
		
	}
	
	@Override
	public double evalEnergy(Value[] args)
	{
		double[][] top = FactorFunctionUtilities.toDouble2DArray(args[0].getObject());
		double[][] bottom = FactorFunctionUtilities.toDouble2DArray(args[1].getObject());
		double[] distribution = FactorFunctionUtilities.toDoubleArray(args[2].getObject());
		double hdelta = FactorFunctionUtilities.toDouble(args[3].getDouble());
		boolean leftRight = FactorFunctionUtilities.toBoolean(args[4].getBoolean());
		boolean useDist = FactorFunctionUtilities.toBoolean(args[5].getBoolean());
		
		double diff = 0;
		
		if (leftRight)
		{
			for (int i = 0; i < top[0].length; i++)
			{
				double tmp = top[1][i] - bottom[0][i];
				diff = tmp*tmp;
			}
			
		}
		else
		{
			for (int i = 0; i < top[0].length; i++)
			{
				double tmp = top[3][i] - bottom[2][i];
				diff = tmp*tmp;
			}
		}
		diff = Math.sqrt(diff);
		int ind = (int)(diff/hdelta);
		if (ind > distribution.length-1)
			ind = distribution.length-1;
		
		if (useDist)
			return -Math.log(distribution[ind]);
		else
			return diff;
		
	}

}
