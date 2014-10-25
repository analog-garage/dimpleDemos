import org.gradle.api.tasks.Exec

class RunMatlabScript extends Exec
{
	public setScript(File scriptFile)
	{
		workingDir = project.rootProject.rootDir
		executable = 'matlab'

		def scriptPath = scriptFile.getAbsolutePath()

		String logFilename = scriptPath
		int i = logFilename.lastIndexOf('.')
		if (i > 0) {
			logFilename = logFilename.substring(0, i)
		}
		logFilename = logFilename + '.log'

		def logFile = new File(logFilename)

		List<String> args = new ArrayList<String>()
		args.add('-nodesktop')
		args.add('-minimize')
		args.add('-noFigureWindows')
		args.add('-nosplash')
		args.add('-wait')
		args.add('-logfile')
		args.add(logFile.getAbsolutePath())
		args.add('-r')
		args.add("testScript('" + scriptPath + "')")

		setArgs(args);
	}
}